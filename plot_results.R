# Imports results from study 1 for plotting and analysis
# Created by: Oct 5, 2025 Peter S. Hovmand 
# Revised by: Nov 2, 2025 Peter S. Hovmand adapted to strategy study

# import results
library(readr)
library(tidyverse)

# Modify the file name for the results to be plotted
results <- read_csv("sens_study_results (3).csv")

# Create a variable that can be used as a label for the scenarios.
# Modify this to make sense and make it easy to interpret results in graphs,
# frequency distributions, summary statistics, etc. Note that this 
# approach only works for scenarios involing 5 or fewer switches
vars <- names(results)
SW_vec <- grep("SW", vars)

# create a vector to summarize the policy switches that are on
scenario <- apply(results[,vars[SW_vec]],1, paste0, collapse="-")

# select the final population for comparisons against policy 
# scenarios
results %>%
  mutate(Scenario = as.factor(scenario)) %>%
  mutate(`Final Population` = Population) %>%
  select(Scenario, `Final Population`) -> tmp

# create a vector with scenarios sorted by their means
tmp %>%
  group_by(Scenario) %>%
  summarize(median = median(`Final Population`)) %>%
  arrange(median) %>% 
  select(median) %>% min() -> min_median

# sort the results from highest to lowest and show
# the top 10 scenarios
tmp %>%
  arrange(desc(`Final Population`)) %>% head(10) 

# construct a plot ordered plot of the the strategies by the final 
# value of the population
tmp %>%
  mutate(Scenario = fct_reorder(Scenario, `Final Population`, .fun='median')) %>%
  ggplot(aes(y=Scenario, x=`Final Population`)) +
    geom_violin(trim=FALSE) +
    geom_vline(xintercept = min_median, color = "blue", linetype = "dashed") +
    theme_minimal()
  


