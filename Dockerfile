# Neovim Development Environment with Full Configuration
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    NVIM_APPNAME=nvim \
    XDG_CONFIG_HOME=/root/.config \
    XDG_DATA_HOME=/root/.local/share \
    XDG_STATE_HOME=/root/.local/state \
    XDG_CACHE_HOME=/root/.cache

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip \
    tar \
    gzip \
    build-essential \
    ripgrep \
    fd-find \
    xclip \
    python3 \
    python3-pip \
    ca-certificates \
    gnupg \
    locales \
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Neovim v0.11.5
RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz \
    && tar -xzf nvim-linux-x86_64.tar.gz -C /usr/local --strip-components=1 \
    && rm nvim-linux-x86_64.tar.gz

# Install Node.js v24 LTS (required for Copilot)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir --break-system-packages pynvim neovim

# Create necessary directories
RUN mkdir -p /root/.config/nvim /root/.local/share/nvim /root/.local/state/nvim /root/.cache/nvim

# Copy Neovim configuration
COPY . /root/.config/nvim/

# Set working directory
WORKDIR /workspace

# Verify installations
RUN nvim --version && node --version && npm --version

# Default command
CMD ["/bin/bash"]

# Labels
LABEL maintainer="mk1121" \
      description="Neovim development environment with full configuration" \
      version="1.0" \
      nvim.version="0.11.5" \
      node.version="24.x"
