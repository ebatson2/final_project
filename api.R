# import libraries
library(readr)
library(plumber)
library(tidymodels)
library(DescTools)

# read in data
df <- readr::read_csv("diabetes_binary_health_indicators_BRFSS2015.csv")

set.seed(29)

# pull out response variable processing since it messes up the prediction step
df <- df |>
  mutate(Diabetes_binary=as.factor(Diabetes_binary))

# recipe for random forest
rf_recipe <- recipe(Diabetes_binary ~ HighChol + Smoker + Sex + Income + BMI, data=df) |>
  step_mutate(HighChol=as.factor(HighChol)) |>
  step_mutate(Smoker=as.factor(Smoker)) |>
  step_mutate(Sex=as.factor(Sex)) |>
  step_mutate(Income=as.factor(Income)) |>
  step_dummy(HighChol, Smoker, Sex, Income)

# use random forest model from parsnip
rf_model <- rand_forest(mtry = 4) |>
  set_engine("ranger") |>
  set_mode("classification")

# create random forest workflow
rf_wfl <- workflow() |>
  add_recipe(rf_recipe) |>
  add_model(rf_model)

# fit the model
rf_final_model <- rf_wfl |>
  fit(df)

# calculate default values for each predictor variable in model
HighChol_mode <- Mode(df$HighChol)
Smoker_mode <- Mode(df$Smoker)
Sex_mode <- Mode(df$Sex)
Income_mode <- Mode(df$Income)
BMI_ave <- ave(df$BMI)

#* Get model predictions
#* @param HighChol whether the subject has high cholesterol (1=yes, 0=no)
#* @param Smoker whether the subject has smoked at least 100 cigarettes in their life (1=yes, 0=no)
#* @param Sex (1=male, 0=female)
#* @param Income subject's income level (1=less than $10,000, 2=less than $15,000, 3=less than $20,000, 4=less than $25,000, 5=less than $35,000, 6=less than $50,000, 7=less than $75,000, 8=more than $75,000)
#* @param BMI subject's BMI
#* @get /pred
function(HighChol=HighChol_mode[1], Smoker=Smoker_mode[1], Sex=Sex_mode[1], Income=Income_mode[1], BMI=BMI_ave[1]){
  
  input=tibble('HighChol'=HighChol_mode[1], 'Smoker'=Smoker_mode[1], 'Sex'=Sex_mode[1], 'Income'=Income_mode[1], 'BMI'=BMI_ave[1])
  prediction <- predict(rf_final_model, input, type='class')
  message <- ifelse(prediction==0, "no diabetes", "prediabetes of diabetes")
  return (message)
}

# 3 example api calls:
# http://localhost:5459/pred?HighChol=1
# http://localhost:5459/pred?HighChol=1&Smoker=1&Sex=1&Income=1&BMI=35
# http://localhost:5459/pred?HighChol=0&BMI=20

#* Name and site link
#* @serializer html
#* @get /info
function(){
  # return ("<div>
  #           <p>Elizabeth Batson</p>
  #           <a href=https://ebatson2.github.io/final_project/>https://ebatson2.github.io/final_project/</a>
  #         </div>")
  
  return ("Elizabeth Batson\nhttps://ebatson2.github.io/final_project/")
}

#* Plot of confusion matrix
#* @serializer html
#* @get /confusion
function(){
  return ("
          <table>
            <tr>
              <td></td>
              <th>Truth</th>
              <td></td>
            </tr>
            <tr>
              <th>Prediction<th>
              <td>0</td>
              <td>1</td>
            </tr>
            <tr>
            <td>0</td>
              <td>217,826</td>
              <td>34,407</td>
            </tr>
            <tr>
              <td>1</td>
              <td>508</td>
              <td>939</td>
            </tr>
          </table>")
}