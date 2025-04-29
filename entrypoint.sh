#!/bin/sh
# Exit script immediately if any command fails
set -e

echo ">>> Starting targets pipeline..."
# Run the pipeline using Rscript - It will use the default _targets.R
Rscript -e "targets::tar_make()" > /app/tar_make.log 2>&1 || echo "tar_make exited with non-zero status $?"
# Log pipeline status and output
echo ">>> Pipeline finished. Exit status: $?. Log:"
cat /app/tar_make.log || echo "Log file not found."

# --- Section for Copying Outputs ---
echo ">>> Copying outputs..."

# Define base directory and output directory inside container
APP_DIR="/app"
OUTPUT_DIR="${APP_DIR}/output"

# Create output directory inside container (safe even if it exists)
mkdir -p "$OUTPUT_DIR"

# --- Copy index.html (HTML Report) ---
RENDERED_HTML="index.html"
if [ -f "${APP_DIR}/${RENDERED_HTML}" ]; then
  echo "Copying ${RENDERED_HTML} to ${OUTPUT_DIR}/"
  cp "${APP_DIR}/${RENDERED_HTML}" "${OUTPUT_DIR}/"
else
  echo "Warning: ${APP_DIR}/${RENDERED_HTML} not found."
fi

# --- Copy index_files (Report Assets) ---
RENDERED_FILES_DIR="index_files" # Default name Quarto uses
if [ -d "${APP_DIR}/${RENDERED_FILES_DIR}" ]; then
  echo "Copying ${RENDERED_FILES_DIR}/ to ${OUTPUT_DIR}/"
  # Use -a flag for archive mode (preserves permissions, etc.) and recursive
  cp -a "${APP_DIR}/${RENDERED_FILES_DIR}" "${OUTPUT_DIR}/"
else
  echo "Note: Directory ${APP_DIR}/${RENDERED_FILES_DIR} not found."
fi

# --- ADDED: Copy _targets/objects directory ---
TARGETS_OBJECTS_DIR="_targets/objects"
if [ -d "${APP_DIR}/${TARGETS_OBJECTS_DIR}" ]; then
  echo "Copying ${TARGETS_OBJECTS_DIR}/ to ${OUTPUT_DIR}/"
  # Copy the 'objects' directory itself into the output directory
  # This will result in host_output_dir/objects/...
  cp -a "${APP_DIR}/${TARGETS_OBJECTS_DIR}" "${OUTPUT_DIR}/"
else
  echo "Note: Directory ${APP_DIR}/${TARGETS_OBJECTS_DIR} not found (pipeline might have failed)."
fi
# --- END ADDED SECTION ---

# --- Copy project assets directory (Optional) ---
ASSETS_DIR="assets"
if [ -d "${APP_DIR}/${ASSETS_DIR}" ]; then
  echo "Copying ${ASSETS_DIR}/ to ${OUTPUT_DIR}/"
  cp -a "${APP_DIR}/${ASSETS_DIR}" "${OUTPUT_DIR}/"
else
  echo "Note: Directory ${APP_DIR}/${ASSETS_DIR} not found."
fi

echo ">>> Entrypoint script finished."
