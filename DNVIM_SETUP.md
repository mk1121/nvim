# dnvim - Docker Neovim Setup Guide

Quick setup guide to use Neovim configuration via Docker on any machine.

## 📋 Prerequisites

- Docker installed and running
- Internet connection (for first time)

## 🚀 Quick Setup (3 Methods)

### Method 1: Direct Docker Command (No Installation)

**Basic usage:**
```bash
# Edit a file
docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest nvim myfile.txt

# Interactive mode
docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest
```

**With clipboard support:**
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  mk1121/nvim:latest nvim myfile.txt
```

---

### Method 2: Shell Alias (Recommended)

**For Bash users** - Add to `~/.bashrc`:
```bash
# dnvim - Docker Neovim
alias dnvim='docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest nvim'

# dnvim-shell - Interactive shell with nvim
alias dnvim-shell='docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest'

# dnvim-update - Pull latest image
alias dnvim-update='docker pull mk1121/nvim:latest'
```

**For Zsh users** - Add to `~/.zshrc`:
```zsh
# dnvim - Docker Neovim
alias dnvim='docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest nvim'

# dnvim-shell - Interactive shell with nvim
alias dnvim-shell='docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest'

# dnvim-update - Pull latest image
alias dnvim-update='docker pull mk1121/nvim:latest'
```

**Reload your shell:**
```bash
source ~/.bashrc  # for Bash
# or
source ~/.zshrc   # for Zsh
```

**Usage after alias:**
```bash
dnvim file.txt           # Edit file
dnvim file1.py file2.js  # Edit multiple files
dnvim-shell              # Open bash shell with nvim
dnvim-update             # Update to latest version
```

---

### Method 3: Standalone Script (Most Features)

**Create the script:**
```bash
# Create dnvim script
cat > ~/dnvim << 'EOF'
#!/bin/bash

# dnvim - Docker Neovim wrapper
DOCKER_IMAGE="mk1121/nvim:latest"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running!"
    exit 1
fi

# Pull image if not exists
if ! docker image inspect "$DOCKER_IMAGE" > /dev/null 2>&1; then
    echo "Pulling Docker image..."
    docker pull "$DOCKER_IMAGE"
fi

# Run Docker Neovim
if [ $# -eq 0 ]; then
    # No arguments - interactive shell
    docker run -it --rm \
        -v $(pwd):/workspace \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY=$DISPLAY \
        $DOCKER_IMAGE /bin/bash
else
    # Arguments provided - pass to nvim
    docker run -it --rm \
        -v $(pwd):/workspace \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY=$DISPLAY \
        $DOCKER_IMAGE nvim "$@"
fi
EOF

# Make it executable
chmod +x ~/dnvim

# Move to PATH (optional - requires sudo)
sudo mv ~/dnvim /usr/local/bin/dnvim

# Or add to PATH without sudo
mkdir -p ~/bin
mv ~/dnvim ~/bin/
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Usage:**
```bash
dnvim file.txt    # Edit file
dnvim             # Interactive mode
```

---

## 📖 Usage Examples

### Basic File Editing
```bash
# Edit single file
dnvim myfile.py

# Edit multiple files
dnvim file1.txt file2.txt

# Open file explorer
dnvim .
```

### Advanced Usage
```bash
# Run Neovim command
dnvim -c "PluginStatus" file.txt

# Edit with specific options
dnvim -u NONE file.txt  # Skip config

# Diff mode
dnvim -d file1.txt file2.txt
```

### Interactive Shell
```bash
# Start shell, then use nvim inside
dnvim-shell
# Inside container:
nvim file.txt
exit
```

### With Network Access (for LSP)
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  --network=host \
  mk1121/nvim:latest nvim file.py
```

### Persistent Plugin Data
```bash
# Create volumes
docker volume create nvim-data
docker volume create nvim-cache

# Run with volumes
docker run -it --rm \
  -v $(pwd):/workspace \
  -v nvim-data:/root/.local/share/nvim \
  -v nvim-cache:/root/.cache/nvim \
  mk1121/nvim:latest nvim file.txt
```

---

## 🔧 Setup on Different Systems

### Windows (WSL2)
```powershell
# In PowerShell
docker run -it --rm -v ${PWD}:/workspace mk1121/nvim:latest nvim file.txt

# Or in WSL2 terminal (use Linux commands above)
```

### macOS
```bash
# Same as Linux
alias dnvim='docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest nvim'
```

### Remote Server (SSH)
```bash
# SSH into server, then:
docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest nvim file.txt
```

---

## ⚙️ Configuration Options

### Custom Environment Variables
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -e NVIM_APPNAME=nvim \
  -e TERM=xterm-256color \
  mk1121/nvim:latest nvim
```

### Custom Working Directory
```bash
docker run -it --rm \
  -v /path/to/project:/workspace \
  -w /workspace \
  mk1121/nvim:latest nvim
```

### Run as Current User
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -u $(id -u):$(id -g) \
  mk1121/nvim:latest nvim file.txt
```

---

## 🎯 First Time Setup

### Step 1: Install Docker
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Logout and login again for group changes
```

### Step 2: Pull the Image
```bash
docker pull mk1121/nvim:latest
```

### Step 3: Test It
```bash
docker run -it --rm mk1121/nvim:latest nvim --version
```

### Step 4: Create Alias
```bash
echo 'alias dnvim="docker run -it --rm -v \$(pwd):/workspace mk1121/nvim:latest nvim"' >> ~/.bashrc
source ~/.bashrc
```

### Step 5: Use It!
```bash
dnvim myfile.txt
```

---

## 🐛 Troubleshooting

### Issue: Docker not found
```bash
# Check if Docker is installed
docker --version

# If not, install it:
curl -fsSL https://get.docker.com | sh
```

### Issue: Permission denied
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Logout and login again
```

### Issue: Clipboard not working
```bash
# Enable X11 forwarding
xhost +local:docker

# Run with X11
docker run -it --rm \
  -v $(pwd):/workspace \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  mk1121/nvim:latest nvim
```

### Issue: Slow first startup
This is normal - plugins are installing. Wait a few seconds.

### Issue: LSP not working
```bash
# Inside container, install LSP server:
nvim
:Mason
# Navigate and press 'i' to install
```

---

## 🔄 Updating

### Update Docker Image
```bash
docker pull mk1121/nvim:latest

# Or use alias
dnvim-update
```

### Update Plugins Inside Container
```bash
dnvim
# Inside Neovim:
:Lazy sync
```

---

## 💡 Pro Tips

### 1. Create Shell Function (Better than alias)
Add to `~/.bashrc` or `~/.zshrc`:
```bash
dnvim() {
    docker run -it --rm \
        -v "$(pwd)":/workspace \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY=$DISPLAY \
        --network=host \
        mk1121/nvim:latest nvim "$@"
}
```

### 2. Docker Compose Setup
Create `docker-compose.yml`:
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

volumes:
  nvim-data:
  nvim-cache:
```

Usage:
```bash
docker-compose run --rm nvim nvim file.txt
```

### 3. Set as Git Editor
```bash
git config --global core.editor "docker run -it --rm -v \$(pwd):/workspace mk1121/nvim:latest nvim"
```

### 4. Persistent Configuration
Mount your own config:
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.config/nvim:/root/.config/nvim:ro \
  mk1121/nvim:latest nvim
```

---

## 📚 Quick Reference

| Command | Description |
|---------|-------------|
| `dnvim file.txt` | Edit file |
| `dnvim .` | Open file explorer |
| `dnvim-shell` | Interactive shell |
| `dnvim-update` | Update image |
| `docker pull mk1121/nvim:latest` | Manual update |
| `docker images \| grep nvim` | Check installed versions |
| `docker rmi mk1121/nvim:latest` | Remove image |

---

## 🌐 Links

- **Docker Hub**: https://hub.docker.com/r/mk1121/nvim
- **GitHub**: https://github.com/mk1121/nvim
- **Documentation**: Full README in repository

---

## 📝 Notes

- Current directory is mounted to `/workspace` in container
- All changes persist (files edited in place)
- First run may take 30-60 seconds (plugins installing)
- Internet required for first pull only
- Container is deleted after exit (--rm flag)
- Image size: ~735 MB (downloads once)

---

**Last Updated**: 2025-11-10
**Version**: 1.0
**Maintainer**: mk1121
