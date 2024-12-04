# import libraries
library(readr)
library(plumber)

# read in data
df <- readr::read_csv("diabetes_binary_health_indicators_BRFSS2015.csv")

#* @param predictor1 the first possible predictor
#* @get /pred
function(predictor1=0){
  
  # later: return prediction
  return (NULL)
}

# 3 example api calls:
# http://localhost:EX_PORT/pred?predictor1=ex_value


#* @get /info
function(){
  
  # later: return message with your name and URL for rendered github pages site
  return (NULL)
}

#* Plot of confusion matrix
#* @serializer png
#* @get /confusion
function(){
  
  # later: return plot of confusion matrix for model fit (entire dataset)
  return (NULL)
}