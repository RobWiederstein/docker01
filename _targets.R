# File: _targets.R (Corrected Version)
library(targets)
library(tarchetypes)
library(quarto)

source("./R/functions.R")
tar_option_set(packages = c("tibble", "dplyr", "DT", "readr", "ggplot2", "here"))
mtcars_url <- "https://raw.githubusercontent.com/selva86/datasets/refs/heads/master/mtcars.csv"

tar_plan(
  tar_target(
    name = mtcars_csv_file,
    command = download_mtcars_csv(
      data_url = mtcars_url,
      output_path = "data/mtcars.csv"
    ),
    format = "file"
  ),
  tar_target(
    name = mtcars_raw,
    command = readr::read_csv(mtcars_csv_file, show_col_types = FALSE)
  ),
  tar_target(
    name = mtcars_plot,
    command = plot_mtcars(mtcars_raw)
  ),
  tar_quarto(
    report,
    path = here::here("index.qmd"),
    quiet = FALSE
  )
)
