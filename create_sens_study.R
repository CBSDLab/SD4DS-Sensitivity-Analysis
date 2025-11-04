# This creates the study files for the "Limits to Growth" 
# sensitivity analysis

# Load and view the template
library(readr)
library(tidyverse)
template <- read_csv("Template.csv")

# Find the variable names with switches for turning policies on
# and off where 1=on and 0=off. 
SW_vec <- grep("[.]SW", names(template))
SW_vars <- names(template[SW_vec])

# Create a list of lists with switch variables and values. 
# Note that for this first strategy study all the defaul effect 
# sizes of 0.5 are used which means that the "total" effect size 
# of the strategy is the sum of all the active interventions
SW_list <- list(
  "IP1 Crude Birth Rate.SW" = c(0,1),
  "IP2 Mortality Rate.SW"= c(0,1),
  "IP3 Carrying Capacity.SW" = c(0,1),
  "IP4 Effect of Population Size on Births.SW" = c(0,1)
)

# Create a data frame with all combinations
study_df<-expand.grid(SW_list)

# Create the strategy_study2_df where the sum of effect sizes will be
# ES_total
ES_total <- 0.5

# Find the variable names with the effect sizes
ES_vec <- grep("ES", names(template))
ES_vars <- names(template[ES_vec])

# Start with the initial switches
study_df %>%
  
  # Total the number of switches
  mutate(total_sw = rowSums(.)) %>%
  
  # Add columns to the data frame with default effect sizes = 0. Note
  # that check.names needs to be set to false otherwise spaces in 
  # the variable names will replaced with periods, which will be 
  # inconsistent with Stella naming of variables
  add_column(data.frame(
    "IP1 Crude Birth Rate.ES" = 0,                   
    "IP2 Mortality Rate.ES" = 0,                      
    "IP3 Carrying Capacity.ES" = 0,            
    "IP4 Effect of Population Size on Births.ES" = 0,
     check.names = FALSE)) -> study_df
  
# normalize effect sizes  
for (i in 1:length(ES_vars)) {
  # get the position of the switch and ES for intervention i
  SW_var_position <- grep(SW_vars[i],names(study_df))
  ES_var_position <- grep(ES_vars[i],names(study_df))
  
  # calculate the normalized effect size for each policy switch
  # by first checking to see if the switch is on for that scenario
  # and if it is, divide the total effect size by the number of active
  # policies
  ES_norm <- ifelse(study_df[,SW_var_position]==1, 
                    ES_total/study_df$total_sw, 0)
  study_df[,ES_var_position] <- ES_norm
}  

# generate 10 rows of random parameters and initial conditions
# for each scenario from a random uniform distribution +/- 50%
# of the initial value
k <- 10 * nrow(study_df) 
parms_init <- data.frame(
  "Initial Carrying Capacity" = 80 * runif(k, 0.5,1.5),      
  "Initial Max Crude Birth Rate" = 0.2 * runif(k, 0.5,1.5),               
  "Initial Mortality Rate" = 0.05 * runif(k, 0.5,1.5),                    
  "Initial Population" = 120 * runif(k, 0.5,1.5),
  check.names = FALSE
)

# combine the random parameters and initial values with the
# scenarios and then save to the study file
parms_init %>%
  cbind(study_df) %>% 
  # Select all the variables except the total_sw for explorting
  # to a .csv file
  select(!total_sw) %>% 
  write_csv("sens_study.csv")
