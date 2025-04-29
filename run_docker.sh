#!/bin/bash

# Exit script immediately if any command fails
set -e

echo ">>> Cleaning previous output..."
rm -rf output
mkdir output

echo ">>> Running Docker container..."
docker run --rm -v "$(pwd)/output:/app/output" docker01:latest

echo ">>> Docker run complete. Checking output directory:"
ls -l output


echo "==> Opening report..."
# Optional: Check if the file exists first
if [ -f "output/index.html" ]; then
  open output/index.html
else
  echo "Warning: output/index.html not found."
fi

echo "==> Script finished."
