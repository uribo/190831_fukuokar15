##################################
# アヤメデータの分類問題
##################################
library(tidymodels)
library(drake)

data(iris)
iris <- as_tibble(iris)

plan_iris_classification <- 
  drake_plan(
    # 1/4 Split -------------------------------------------------------------------
    iris_split = initial_split(iris, prop = 0.6),
    iris_train = training(iris_split),
    iris_test = testing(iris_split), 
    # 2/4 Pre-processing ----------------------------------------------------------
    iris_recipe =
      iris_train %>%
          recipe(formula = Species ~ .) %>%
          step_corr(all_predictors(), threshold = 0.9) %>%
          step_normalize(all_predictors(), -all_outcomes()),
    iris_recipe_comp =
      iris_recipe %>% 
      prep(),
    iris_training =
      juice(iris_recipe_comp),
    iris_testing =
      iris_recipe_comp %>%
      bake(new_data = iris_test),
    # 3/4 Model training -------------------------------------------------------------------
    iris_ranger = 
      rand_forest(trees = 100, mode = "classification") %>%
      set_engine("ranger") %>%
      fit(Species ~ ., data = iris_training),
    iris_rf =
      rand_forest(trees = 100, mode = "classification") %>%
      set_engine("randomForest") %>%
      fit(Species ~ ., data = iris_training),
    # 4/4 Model validation --------------------------------------------------------
    iris_probs =
      iris_ranger %>%
      predict(iris_testing, type = "prob") %>%
      bind_cols(iris_testing))
make(plan_iris_classification)
loadd(plan_iris_classification, list = plan_iris_classification$target)


iris_ranger %>%
  predict(iris_testing) %>%
  bind_cols(iris_testing) %>%
  metrics(truth = Species, estimate = .pred_class)

perf_metrics <- metric_set(accuracy, kap)
iris_ranger %>%
  predict(iris_testing) %>%
  bind_cols(iris_testing) %>%
  perf_metrics(truth = Species, estimate = .pred_class)

iris_probs %>%
  gain_curve(Species, .pred_setosa:.pred_virginica) %>%
  glimpse()

iris_probs %>%
  gain_curve(Species, .pred_setosa:.pred_virginica) %>%
  autoplot()

iris_probs %>%
  roc_curve(Species, .pred_setosa:.pred_virginica) %>%
  autoplot()

predict(iris_ranger, iris_testing, type = "prob") %>%
  bind_cols(predict(iris_ranger, iris_testing)) %>%
  bind_cols(select(iris_testing, Species)) %>%
  metrics(Species, .pred_setosa:.pred_virginica, estimate = .pred_class)

iris_rf %>%
  predict(iris_testing) %>%
  bind_cols(iris_testing) %>%
  metrics(truth = Species, estimate = .pred_class)

