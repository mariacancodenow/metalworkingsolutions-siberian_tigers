library(shiny)
library(tidyverse)
library(glue)
library(DT)


job_ops <- read.csv('../job_ops_23-24.csv')

job_ops <- job_ops |> 
  mutate(hours_diff = completed_production_hours - reestimated_hours, hours_diff_2 = completed_production_hours - est_hours)

hours_ops <- job_ops |>
  filter(completed_production_hours != 0, est_hours != 0) |> 
  group_by(short_description) |> 
  summarise(num_jobs = n(), total_hours = sum(completed_production_hours), avg_hr = mean(completed_production_hours), avg_hr_diff = mean(hours_diff)) |> 
  mutate_if(is.numeric,~round(.,digits=0)) |> 
  arrange(desc(total_hours))

hours_ops_longer <- hours_ops |> 
  select(-c(num_jobs, total_hours)) |> 
  pivot_longer(!short_description, names_to = "measurement", values_to = "hours")

hours_parts <- job_ops |>
  filter(completed_production_hours != 0, reestimated_hours != 0) |> 
  group_by(part_id) |> 
  summarise(num_parts = n(), total_hours = sum(completed_production_hours), avg_hr = mean(completed_production_hours), avg_hr_diff = mean(hours_diff)) |> 
  mutate_if(is.numeric,~round(.,digits=0)) |> 
  arrange(desc(total_hours))

hours_parts <- hours_parts |> 
  filter(avg_hr_diff != 0, num_parts >2)