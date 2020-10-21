##############################
# 1. データ分割 (rsample)
# 2. 特徴量エンジニアリング (recipes)
# 3. モデル定義 (parsnip)
# 4. 性能評価 (yardstick)
# 5. ワークフロー化 (workflows)
# 6. モデルの改善（パラメータ調整、リサンプリング） (tune, resample)
##############################
library(tidymodels)
library(patchwork)
theme_set(theme_light(base_size = 14, base_family = suryulib::jpfont()))
# 地価価格データ ------------------------------------------------------------------
# 地価価格を予測するモデル（回帰問題）
# 地価は対数変換した値を使う
# https://nlftp.mlit.go.jp/ksj/jpgis/datalist/KsjTmplt-L01-v1_1.html
df_lp <-
  readr::read_rds("data/df_lp_kanto_use.rds")
dplyr::glimpse(df_lp)
# log_lp: 地価価格を常用対数した値
# distance_from_station: 駅からの距離(m)
# acreage: 地積(m2)
# current_use: 利用現況。標準地の現在の利用方法。
#   住宅、店舗、事務所、銀行、旅館、給油所、工場、倉庫、農地、山林、医院、空地、作業場、原野、その他、用材、雑木
#   複数のカテゴリになることもある
# building_coverage: 建ぺい率。建築物の延べ面積の敷地面積に対する割合
# building_structure: 建物構造。標準地の建物の構造による区別。
#   SRC：鉄骨・鉄筋コンクリート, RC：鉄筋コンクリート, S：鉄骨造, B：ブロック造, W：木造
#   未記載の場合は UNKNOWN
# .longitude: 経度。地価公示標準地の位置を示す
# .latitude: 緯度。地価公示標準地の位置を示す


# 地価価格の対数変換 --------------------------------------------------------------------
# 変数の値の単位は、モデル自身の性能と共に解釈しやすさに影響することがある
# 異なる単位の値を扱う場合、特に注意が必要。変数間のスケーリングが必要になる
# 対数変換をしても
# priceはマイナスにならない、高額な地価の影響を過度に受けない、分散を安定させる
p1 <- 
  df_lp %>% 
  ggplot(aes(x = 10 ^ log_lp)) +
  geom_histogram(bins = 50, 
                 fill = viridis::plasma(2, end = 0.6)[1]) +
  xlab("地価の公示価格(円/m2)") + 
  scale_x_continuous(labels = scales::comma)
p2 <- 
  df_lp %>% 
  ggplot(aes(x = log_lp)) +
  geom_histogram(bins = 50,
                 fill = viridis::plasma(2, end = 0.6)[2]) +
  xlab("地価の公示価格(円/m2)対数")
p1 + p2 + 
  plot_layout(ncol = 2)
ggsave("figures/landprice_histogram.png", 
       last_plot(),
       width = 8,
       height = 4)

# split -----------------------------------------------------------------
df_lp %>% 
  ggplot(aes(x = log_lp)) +
  geom_density() +
  xlab("地価の公示価格(円/m2)対数") +
  geom_vline(xintercept = quantile(df_lp$log_lp)[-c(1, 5)], 
             color = "green", 
             lty = 2) +
  labs(caption = "波線は四分位点を示す")
ggsave("figures/landprice_density.png", 
       last_plot(),
       width = 4,
       height = 4)

# 四分位点ごとにデータを区切って層別サンプリングを4回実施
# train/testで分布を類似させる
# 分類問題において、ラベル間で不均衡が生じる場合にも有効
# rsample
# initial_split --> train / test に分ける
set.seed(123)
# 全体の8割をanalysis(train)として分割
# 大まかに地価の分布に偏りが生じないように分割
lp_split <-
  df_lp %>% 
  initial_split(prob = 0.8, strata = log_lp)
# Analysis --> 訓練、学習
# Assess --> テスト
lp_train <- 
  lp_split %>% 
  training()
lp_test <-
  lp_split %>% 
  testing()

# 特徴量エンジニアリング ---------------------------------------------------------------------
# recipes
# recipe() --> prep() --> bake()
# recipe() --> workflows::add_recipe()
# recipesの初歩
# step_*()で処理内容を記述
init_lp_recipe <- 
  lp_train %>% 
  recipe(log_lp ~ .) %>%
  step_log(acreage, base = 10)
init_lp_recipe


# どんなstep_*()があるの？ --------------------------------------------------------
ls("package:recipes", pattern = "^step_")
# 他にもXXに特化したパッケージがある
# {textrecipes} ... 文字列
# {embed} ... カテゴリカル(?)
# {themis} ... 不均衡データ

# レシピの処理を追加する -------------------------------------------------------------
# 項目が多いので「other」にまとめる
# （ランク落ちを防ぐ）
ggplot(lp_train, aes(y = current_use)) + 
  geom_bar() + 
  labs(y = NULL)
ggsave("figures/landplace_current_use_count.png", 
       last_plot(),
       width = 5,
       height = 12)

lp_train %>% 
  count(current_use) %>% 
  summarise(n,
            prop = n / sum(n) * 100)

# other
init_lp_recipe <- 
  init_lp_recipe %>% 
  step_mutate(distance_from_station = if_else(distance_from_station == 0,
                                              0.1,
                                              as.double(distance_from_station))) %>% 
  step_log(distance_from_station, base = 10) %>% 
  step_other(current_use, threshold = 0.01) %>% # <<
  step_dummy(all_nominal()) %>%  # << ダミー変数
  step_normalize(all_predictors()) # << 標準化（平均0、分散1）
# 一旦完了。

# レシピの完成、データへの適用 ------------------------------------------------------------------
lp_rec_prepped <- 
  prep(init_lp_recipe)
lp_rec_prepped
# レシピ（特徴量エンジニアリングの処理）を学習データに適用
lp_train_prepped <- 
  lp_rec_prepped %>% 
  bake(new_data = NULL) # 最初に与えたデータ（学習データ）に対して実行
glimpse(lp_train_prepped) # レシピの処理が適用されているか、current_user_other を確認
# all.equal(
#   juice(lp_rec_prepped),
#   bake(lp_rec_prepped, new_data = NULL))
# テストデータにも適用
lp_test_prepped <- 
  lp_rec_prepped %>% 
  bake(new_data = lp_test)

# 初期モデルの作成 ------------------------------------------------------------------
# ここから分岐... まずは単純な回帰モデル。続いてランダムフォレスト
# trainに適用、testにもfitしてみる。続いてtrainを交差検証に回す
# model_spec --> fit()
# model_spec --> workflows::add_model() --> fit()
# parsnip
lm_model <-
  linear_reg() %>%
  set_engine("lm")
class(lm_model) # model_spec
lm_formula_fit <- 
  lm_model %>% 
  fit(log_lp ~ ., data = lp_train_prepped)

lm(log_lp ~ ., data = lp_train_prepped)

# 予測結果のあてはめ -------------------------------------------------------------------------
df_lm_model_predict <- 
  lp_test_prepped %>% 
  select(log_lp) %>% 
  bind_cols(predict(lm_formula_fit, 
                    new_data = lp_test_prepped)) %>% 
  # Add 95% prediction intervals to the results:
  bind_cols(predict(lm_formula_fit, 
                    lp_test_prepped, 
                    type = "pred_int"))

ggplot(df_lm_model_predict, 
       aes(x = log_lp, y = .pred)) + 
  # Create a diagonal line:
  geom_abline(color = "green", lty = 2) + 
  geom_point(alpha = 0.5) + 
  labs(x = "地価価格 (log10)",
       y = "予測された地価価格 (log10)") +
  # Scale and size the x- and y-axis uniformly:
  coord_obs_pred()
ggsave("figures/landprice_lmpredict.png",
       last_plot(),
       width = 4,
       height = 4)

# 2. ランダムフォレストを試そう --------------------------------------------------------
rf_model <-
  rand_forest(trees = 1000,
              mtry = 3) %>%
  set_mode("regression")

rf_model <-
  rf_model %>% 
  set_engine("ranger")
# rf_model <-
#   rf_model %>% 
#   set_engine("randomForest")

rf_model %>%
  translate()

# 3. 勾配ブースティング ------------------------------------------------------------
gb_model <- 
  boost_tree(trees = 1000,
             mtry = 3,
             tree_depth = 4) %>% 
  set_mode("regression")

gb_model <- 
  gb_model %>% 
  set_engine("xgboost")

gb_model %>% 
  fit(log_lp ~ ., data = lp_train_prepped)


# 評価 ----------------------------------------------------------------------
# yardstick
rmse(df_lm_model_predict, 
     truth = log_lp, 
     estimate = .pred) # 0.357
rsq(df_lm_model_predict, 
               truth = log_lp, 
               estimate = .pred)

lp_metrics <- 
  metric_set(rmse, rsq, mae)
lp_metrics(df_lm_model_predict, 
           truth = log_lp, 
           estimate = .pred)

# ワークフロー化 -----------------------------------------------------------------
# これまでの作業をワークフロー化
# 適用するモデルを定義(parsnip)
# --> フォーミュラを宣言
# --> recipesのレシピを与える
# recipesの内容（フォーミュラ、特徴量エンジニアリング）を反映
lp_wflow <-
  workflow() %>% 
  add_recipe(init_lp_recipe) %>% 
  add_model(lm_model) # 線形回帰モデル
lm_fit <- 
  fit(lp_wflow, data = lp_train)

# lp_wflow %>% 
#   update_model(rf_model) %>% 
#   fit(data = lp_train)
# lp_wflow %>% 
#   update_model(gb_model) %>% 
#   fit(data = lp_test)

df_lm_model_predict <- 
  lp_test %>% 
  select(log_lp) %>% 
  bind_cols(predict(lm_fit, new_dat = lp_test))

# ggplot(df_lm_model_predict, 
#        aes(x = log_lp, y = .pred)) + 
#   geom_abline(color = "green", lty = 2) + 
#   geom_point(alpha = 0.5) + 
#   labs(x = "地価価格 (log10)",
#        y = "予測された地価価格 (log10)") +
#   coord_obs_pred()
rmse(df_lm_model_predict, truth = log_lp, estimate = .pred) # 0.349
lp_metrics <- 
  metric_set(rmse, rsq, mae)
lp_metrics(df_lm_model_predict, 
           truth = log_lp, 
           estimate = .pred)
# --> ここで一区切り。回帰モデルではなくて別のモデルを試そう、前処理に一工夫しよう
# workflowsのご利益をここで感じる


# モデルの改善1) 交互作用項 -----------------------------------------------------------------
#  building_structureの違いによって地価価格が異なる
ggplot(lp_train, 
       aes(x = acreage, y = log_lp)) + 
  geom_point(alpha = .2) + 
  facet_wrap(~ building_structure, nrow = 1) + 
  geom_smooth(method = lm, formula = y ~ x, se = FALSE, col = "green") + 
  scale_x_log10()
ggsave("figures/landprice_acreage_building_structure_interact.png", 
       last_plot(),
       width = 12,
       height = 4)

# モデルの改善2) スプライン平滑化 ----------------------------------------------------------------
# .latitudeと地価価格の関係 --> 直線では表現しにくい。ばらつきがある
# 自由度をどうする問題は ...　後々tune()で調整
c(2, 5, 20, 200) %>% 
  purrr::map(
    ~ ggplot(lp_train, 
             aes(x = .latitude, y = log_lp)) + 
      geom_point(alpha = .2) + 
      scale_y_log10() +
      geom_smooth(
        method = lm,
        formula = y ~ splines::ns(x, df = .x),
        col = "green",
        se = FALSE) +
      ggtitle(paste(.x, "Spline Terms"))
  ) %>% 
  wrap_plots(nrow = 1)
ggsave("figures/landprice_smoothing.png",
       last_plot(),
       width = 12,
       height = 4)

# モデルの改善 ------------------------------------------------------------------
# これまでのレシピに追加する
second_lp_recipe <- 
  init_lp_recipe %>% 
  step_interact( ~ acreage:starts_with("building_structure")) %>% # <<
  step_ns(.latitude, .longitude, deg_free = 20) # <<

# modelの改善 ----------------------------------------------------------------
# 1. 特徴量エンジニアリングの内容を修正
lp_wflow <-
  lp_wflow %>%
  update_recipe(second_lp_recipe) ## <<
lm_fit <- 
  fit(lp_wflow, lp_train)
df_lm_model_predict <- 
  lp_test %>% 
  select(log_lp) %>% 
  bind_cols(predict(lm_fit, new_dat = lp_test))
lp_metrics(df_lm_model_predict, 
           truth = log_lp, 
           estimate = .pred)
# 2. モデルの変更
lp_wflow <- 
  lp_wflow %>% 
  update_model(rf_model) # ランダムフォレスト
rf_fit <- 
  fit(lp_wflow, lp_train)
df_rf_model_predict <- 
  lp_test %>% 
  select(log_lp) %>% 
  bind_cols(predict(rf_fit, new_dat = lp_test))
lp_metrics(df_rf_model_predict, 
           truth = log_lp, 
           estimate = .pred)

lp_wflow <- 
  lp_wflow %>% 
  update_model(gb_model)
gb_fit <- 
  fit(lp_wflow, lp_train)
df_gb_model_predict <- 
  lp_test %>% 
  select(log_lp) %>% 
  bind_cols(predict(gb_fit, new_dat = lp_test))
lp_metrics(df_gb_model_predict, 
           truth = log_lp, 
           estimate = .pred)

# モデル比較
df_lm_model_predict %>% 
  mutate(model = "linaer regression") %>% 
  bind_rows(
    df_rf_model_predict %>% 
      mutate(model = "random forest"),
    df_gb_model_predict %>% 
      mutate(model = "gradient boosting")
  ) %>% 
  mutate(model = forcats::fct_inorder(model)) %>% 
  ggplot(aes(x = log_lp, y = .pred, color = model)) + 
  geom_abline(color = "green", lty = 2) + 
  geom_point(alpha = 0.5) + 
  labs(x = "地価価格 (log10)",
       y = "予測された地価価格 (log10)") +
  facet_wrap(~ model, nrow = 1) + 
  coord_obs_pred() +
  scale_color_viridis_d(option = "plasma", end = 0.6) +
  guides(color = FALSE)
ggsave("figures/landplace_3model_compare.png",
       last_plot(),
       width = 12,
       height = 4)


# バリデーションセット --------------------------------------------------------------
set.seed(55)
lp_folds <- vfold_cv(lp_train, 
                     v = 10)
lp_folds

# パラメータ探索 -----------------------------------------------------------------
# グリッドサーチ、ベイズ最適化、 etc
# 3. パラメータを調整しよう (パラメータ探索)
# 3つのパラメータ mtry, trees, min_n
(cores <- parallel::detectCores())
rf_wflow <- 
  workflow() %>%
  add_model(rand_forest(mtry = tune(), # << 
                        trees = tune()) %>% # <<
              set_engine("ranger",
                         num.threads = cores) %>%
              set_mode("regression")) %>%
  add_recipe(second_lp_recipe)
set.seed(345)
rf_res <- 
  rf_wflow %>% 
  tune_grid(val_set,
            grid = 25,
            control = control_grid(save_pred = TRUE),
            metrics = metric_set(rmse))
autoplot(rf_res)
ggsave("figures/landplace_rf_grid_search.png", 
       last_plot(),
       width = 8,
       height = 4)

reprex::reprex({

}, venue = "rtf")

# ベストモデルとパラメータ ------------------------------------------------------------
# rf_res %>% 
#   collect_predictions()
rf_best <- 
  rf_res %>% 
  show_best(metric = "rmse")
rf_best

# kを変える
tune_lp_recipe <- 
  init_lp_recipe %>% 
  step_interact( ~ acreage:starts_with("building_structure")) %>%
  step_ns(.latitude, .longitude, deg_free = tune("coords")) # <<

spline_res <-
  tune_grid(rf_model, 
            tune_lp_recipe, 
            resamples = lp_folds, 
            grid = expand.grid(coords = c(2, 5, 20, 200)))
spline_res %>% 
  show_best(metric = "rmse")

rf_model_tuned <- 
  rand_forest(mtry = rf_best$mtry[1], 
              trees = rf_best$trees[1]) %>% 
  set_engine("ranger", 
             num.threads = cores, 
             importance = "impurity") %>% 
  set_mode("regression")

reprex::reprex({
  last_lp_recipe <- 
    init_lp_recipe %>% 
    step_interact( ~ acreage:starts_with("building_structure")) %>% 
    step_ns(.latitude, .longitude, deg_free = 5)
}, venue = "rtf")

last_lp_recipe <- 
  init_lp_recipe %>% 
  step_interact( ~ acreage:starts_with("building_structure")) %>% 
  step_ns(.latitude, .longitude, deg_free = 5)

rf_wflow_tuned <- 
  rf_wflow %>% 
  update_recipe(last_lp_recipe) %>% 
  update_model(rf_model_tuned) # << 
last_rf_fit <- 
  rf_wflow_tuned %>% 
  last_fit(lp_split) # <<
last_rf_fit %>% 
  collect_metrics()
last_rf_fit
