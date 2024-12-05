# start from the rstudio/plumber image
FROM rstudio/plumber

# install the linux libraries needed for plumber
RUN apt-get update -qq && apt-get install -y  libssl-dev  libcurl4-gnutls-dev  libpng-dev pandoc 

# install packages
RUN R -e "install.packages(c('readr', 'tidymodels', 'DescTools', 'ranger'))"

# copy api.R and data from the current directory into the container
COPY api.R api.R
COPY diabetes_binary_health_indicators_BRFSS2015.csv diabetes_binary_health_indicators_BRFSS2015.csv

# open port to traffic
EXPOSE 5459

# when the container starts, start the myAPI.R script
ENTRYPOINT ["R", "-e", \
    "pr <- plumber::plumb('api.R'); pr$run(host='0.0.0.0', port=5459)"]