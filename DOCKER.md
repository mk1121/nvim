# Docker Image for Neovim Configuration

Pre-configured Neovim development environment with all plugins and dependencies.

## 🐳 Quick Start

### Pull the Image

```bash
# Latest version
docker pull mk1121/nvim:latest

# Specific version
docker pull mk1121/nvim:v1.0
docker pull mk1121/nvim:0.11.5
```

### Run Neovim in Docker

**Interactive session:**
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  mk1121/nvim:latest
```

**Edit a file directly:**
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  mk1121/nvim:latest nvim /workspace/myfile.txt
```

**With clipboard support (Linux):**
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  mk1121/nvim:latest
```

## 📦 What's Included

### Software Versions
- **Neovim**: v0.11.5
- **Node.js**: v24.x LTS
- **Python**: 3.12 with pynvim
- **OS**: Ubuntu 24.04

### Pre-installed Tools
- `git` - Version control
- `ripgrep` - Fast search
- `fd-find` - Fast file finder
- `curl`, `wget` - Download tools
- `build-essential` - Compilation tools
- `xclip` - Clipboard support

### Neovim Configuration
- ✅ All plugins configured
- ✅ LSP ready (Mason installed)
- ✅ Copilot ready (requires auth)
- ✅ Treesitter configured
- ✅ Telescope with fuzzy finder
- ✅ Git integration (gitsigns)
- ✅ Which-key keybinding hints
- ✅ Full autocompletion (nvim-cmp)

## 🚀 Usage Examples

### Development Container

**Create a docker-compose.yml:**
```yaml
version: '3.8'

services:
  nvim:
    image: mk1121/nvim:latest
    volumes:
      - .:/workspace
      - nvim-data:/root/.local/share/nvim
      - nvim-cache:/root/.cache/nvim
    working_dir: /workspace
    stdin_open: true
    tty: true
    command: /bin/bash

volumes:
  nvim-data:
  nvim-cache:
```

**Start the container:**
```bash
docker-compose up -d
docker-compose exec nvim bash
```

### Project-Specific Setup

**With custom configuration:**
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.config/nvim:/root/.config/nvim:ro \
  mk1121/nvim:latest
```

### Copilot Setup in Docker

```bash
# Start container
docker run -it --rm \
  -v $(pwd):/workspace \
  mk1121/nvim:latest bash

# Inside container
nvim
:Copilot auth
# Follow the browser authentication
```

### Install Additional LSP Servers

```bash
# Inside the container
nvim
:Mason
# Press 'i' on the desired LSP server to install
```

## 🎯 Common Tasks

### Edit Files
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  mk1121/nvim:latest nvim file.py
```

### Batch Processing
```bash
docker run --rm \
  -v $(pwd):/workspace \
  mk1121/nvim:latest \
  nvim -c "source script.vim" -c "qa"
```

### As Default Editor
Add to your shell rc file:
```bash
alias nvim='docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest nvim'
```

## 🔧 Customization

### Build Your Own Image

**Dockerfile:**
```dockerfile
FROM mk1121/nvim:latest

# Add your customizations
RUN nvim --headless "+MasonInstall rust-analyzer" +qa

# Install additional tools
RUN apt-get update && apt-get install -y your-package

# Copy custom config
COPY my-config.lua /root/.config/nvim/lua/user/
```

**Build:**
```bash
docker build -t my-nvim:latest .
```

### Persist Data Across Sessions

**Create volumes:**
```bash
docker volume create nvim-data
docker volume create nvim-cache
```

**Use volumes:**
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v nvim-data:/root/.local/share/nvim \
  -v nvim-cache:/root/.cache/nvim \
  mk1121/nvim:latest
```

## 📊 Image Information

### Tags Available
- `latest` - Most recent build
- `v1.0` - Version 1.0 release
- `0.11.5` - Neovim version 0.11.5

### Image Size
- Compressed: ~300 MB
- Uncompressed: ~735 MB

### Architecture
- Platform: linux/amd64

## 🔍 Troubleshooting

### Plugins Not Loading
The container doesn't pre-install plugins to keep size manageable. On first run:
```bash
nvim
# Wait for lazy.nvim to install plugins
:Lazy sync
```

### Clipboard Not Working
Ensure X11 forwarding is enabled:
```bash
xhost +local:docker
docker run -it --rm \
  -v $(pwd):/workspace \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  mk1121/nvim:latest
```

### Permission Issues
Run with your user ID:
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -u $(id -u):$(id -g) \
  mk1121/nvim:latest
```

### LSP Server Not Working
Install the required LSP server:
```bash
nvim
:Mason
# Navigate to the server and press 'i' to install
```

## 🌐 Links

- **Docker Hub**: https://hub.docker.com/r/mk1121/nvim
- **GitHub**: https://github.com/mk1121/nvim
- **Pull Command**: `docker pull mk1121/nvim:latest`

## 📝 Environment Variables

You can customize the environment:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -e NVIM_APPNAME=nvim \
  -e XDG_CONFIG_HOME=/root/.config \
  mk1121/nvim:latest
```

## 🔐 Security Notes

- Container runs as root by default
- For production use, create a non-root user
- Don't store sensitive data in the container
- Use volumes for persistent data

## 🆕 Updates

To get the latest version:
```bash
docker pull mk1121/nvim:latest
docker images # Verify new image
```

## 💡 Tips

1. **Alias for convenience:**
   ```bash
   alias nvim-docker='docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest nvim'
   ```

2. **Persistent plugin installation:**
   Use named volumes to persist plugin installations across containers.

3. **Network access:**
   Add `--network=host` for full network access (required for some LSP servers).

4. **GPU support:**
   For GPU-accelerated tasks, add `--gpus all` flag.

## 📄 License

This Docker image uses the same license as the Neovim configuration it contains.

---

**Maintainer**: mk1121
**Version**: 1.0
**Last Updated**: 2025-11-10
