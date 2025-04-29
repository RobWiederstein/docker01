# R/functions.R

#' Download mtcars CSV data
#'
#' Downloads the mtcars dataset from a specified URL to a specified path,
#' creating the directory if necessary.
#'
#' @param data_url The URL string for the CSV file.
#' @param output_path The desired local file path string for saving the data.
#'
#' @return The output_path string (for targets file tracking).
#'
download_mtcars_csv <- function(data_url, output_path) {

  # Get the directory name from the path
  output_dir <- dirname(output_path)

  # Create the target directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    message(paste("Creating directory:", output_dir))
    dir.create(output_dir, recursive = TRUE)
  }

  # Download the file
  message(paste("Downloading", data_url, "to", output_path))
  # download.file requires libcurl system dependency (installed in Dockerfile)
  download.file(url = data_url, destfile = output_path, mode = "wb")

  # Return the path to the downloaded file for targets
  output_path
}

plot_mtcars <- function(data){
  data %>%
    ggplot() +
    aes(x = mpg, y = wt, color = factor(cyl)) +
    geom_point() +
    theme_minimal() +
    labs(
      x = "Miles per Gallon (mpg)",
      y = "Weight (1000 lbs)",
      color = "Cylinders:"
    )
}
