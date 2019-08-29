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
