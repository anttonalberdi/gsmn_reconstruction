setwd("/Users/anttonalberdi/github/campylo_gsmn")

library(tidyverse)

#Load MAG-CMAG mapping table
mapping_file <- read.table("data/mag_trends.tsv",sep="\t",header=T)

#Load relative abundance table
load("data/CC_d7_selected_animals.RData")

#Load depencence table and rename to cmag
dependence <- read.table("data/dependency_ERR4836918_bin_11.tsv",sep="\t",header=F) %>%
  select(mag_id = 1, value = 3)  %>%
  left_join(mapping_file, by = c("mag_id" = "mag_id")) %>%
  select(mag_name = mag_name, value = value)

#Calculate dependencies for all samples
dependence_results <- tibble(names = names(table)) %>%
  mutate(values = map_dbl(seq_along(table), ~ {
    table[[.x]] %>%
      as.data.frame() %>%
      rownames_to_column(var = "mag_name") %>%
      left_join(dependence, by = c("mag_name" = "mag_name")) %>%
      mutate(weight = rel_abu * value) %>%
      summarize(weighted_average = sum(weight)) %>%
      pull(weighted_average) %>%
      as.numeric()
  }))

dependence_results %>%
  add_column(group = c(0,1,0,0,1,1,1,1,1,1)
