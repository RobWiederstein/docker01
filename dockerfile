# Base image using a specific R version for reproducibility
FROM rocker/r-ver:4.4.0

# Prevent interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Install essential system dependencies...
RUN apt-get update -y && apt-get install -y \
    build-essential \
    make \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libcairo2-dev \
    libxt-dev \
    pandoc \
    git \
    curl \
    tree \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Install Quarto CLI ---
ARG QUARTO_VERSION="1.6.43" # Use desired version, 1.4.553 is recent
ARG TARGETARCH
# Ensure curl is installed (should be from previous step)
# Download Quarto CLI .deb package matching the build architecture
RUN curl -o quarto.deb -L "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${TARGETARCH}.deb" && \
    # Install the .deb package using apt-get to handle dependencies
    apt-get update -y && apt-get install -y ./quarto.deb && \
    # Clean up downloaded file and cache
    rm quarto.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
# Verify installation (optional but good)
RUN quarto --version

# Set the working directory inside the container
WORKDIR /app

COPY assets/ /app/assets/

# Copy ONLY renv files first for caching
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R ./renv/

# Install 'remotes'
RUN R -e 'install.packages("remotes")'

# Install specific renv version (replace 1.0.11 if needed)
RUN R -e 'remotes::install_version("renv", version = "1.0.11")'

# Restore packages from lockfile (uses cache if lockfile unchanged)
RUN R -e 'renv::restore()'

# Now copy the rest of your project files
COPY . .

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint script as the default command
CMD ["/entrypoint.sh"]



