# dnvim - Persistent Container Setup

Use a persistent Docker container for faster startup and plugin persistence.

## 🎯 Concept

Instead of creating a new container each time, we:
1. Create a **persistent container** once
2. Start/stop it as needed
3. Execute commands inside it

**Benefits:**
- ✅ Faster startup (no container creation)
- ✅ Plugins persist between sessions
- ✅ LSP servers stay installed
- ✅ Configuration changes persist

---

## 🚀 Quick Setup

### Step 1: Create Persistent Container

```bash
# Create and start the container
docker run -itd \
  --name nvim-container \
  -v $(pwd):/workspace \
  -v nvim-data:/root/.local/share/nvim \
  -v nvim-cache:/root/.cache/nvim \
  --network=host \
  mk1121/nvim:latest /bin/bash

# Get the container ID
CONTAINER_ID=$(docker ps -aqf "name=nvim-container")
echo "Container ID: $CONTAINER_ID"
```

### Step 2: Create dnvim Alias

**For Bash** - Add to `~/.bashrc`:
```bash
# Get container ID (if container exists)
NVIM_CONTAINER_ID=$(docker ps -aqf "name=nvim-container")

# Create dnvim alias using container ID
if [ ! -z "$NVIM_CONTAINER_ID" ]; then
    alias dnvim='docker exec -it $NVIM_CONTAINER_ID nvim'
    alias dnvim-shell='docker exec -it $NVIM_CONTAINER_ID /bin/bash'
else
    # Fallback to direct docker run if container doesn't exist
    alias dnvim='docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest nvim'
fi
```

**For Zsh** - Add to `~/.zshrc`:
```zsh
# Get container ID (if container exists)
NVIM_CONTAINER_ID=$(docker ps -aqf "name=nvim-container")

# Create dnvim alias using container ID
if [ ! -z "$NVIM_CONTAINER_ID" ]; then
    alias dnvim="docker exec -it $NVIM_CONTAINER_ID nvim"
    alias dnvim-shell="docker exec -it $NVIM_CONTAINER_ID /bin/bash"
else
    # Fallback to direct docker run if container doesn't exist
    alias dnvim='docker run -it --rm -v $(pwd):/workspace mk1121/nvim:latest nvim'
fi
```

### Step 3: Reload Shell

```bash
source ~/.bashrc  # for Bash
# or
source ~/.zshrc   # for Zsh
```

### Step 4: Use dnvim

```bash
dnvim myfile.txt
```

---

## 📖 Complete Setup Script

### Option A: Simple Function (Recommended)

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# dnvim - Persistent container function
dnvim() {
    local CONTAINER_NAME="nvim-container"
    local CONTAINER_ID=$(docker ps -aqf "name=$CONTAINER_NAME")
    
    # Create container if it doesn't exist
    if [ -z "$CONTAINER_ID" ]; then
        echo "Creating persistent Neovim container..."
        docker run -itd \
            --name "$CONTAINER_NAME" \
            -v "$HOME/.config/nvim-docker:/root/.config/nvim" \
            -v "$HOME/.local/share/nvim-docker:/root/.local/share/nvim" \
            -v "$HOME/.cache/nvim-docker:/root/.cache/nvim" \
            --network=host \
            mk1121/nvim:latest /bin/bash > /dev/null
        CONTAINER_ID=$(docker ps -aqf "name=$CONTAINER_NAME")
    fi
    
    # Start container if it's stopped
    if [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_ID)" != "true" ]; then
        echo "Starting Neovim container..."
        docker start "$CONTAINER_ID" > /dev/null
    fi
    
    # Mount current directory and execute nvim
    docker exec -it \
        -w /workspace \
        -e "HOST_PWD=$(pwd)" \
        "$CONTAINER_ID" \
        bash -c "cd '$HOST_PWD' 2>/dev/null || cd /workspace; nvim $*"
}

# Helper functions
dnvim-shell() {
    local CONTAINER_ID=$(docker ps -aqf "name=nvim-container")
    if [ ! -z "$CONTAINER_ID" ]; then
        docker exec -it "$CONTAINER_ID" /bin/bash
    else
        echo "Container not running. Run 'dnvim' first."
    fi
}

dnvim-stop() {
    docker stop nvim-container
    echo "Neovim container stopped"
}

dnvim-restart() {
    docker restart nvim-container
    echo "Neovim container restarted"
}

dnvim-remove() {
    docker stop nvim-container 2>/dev/null
    docker rm nvim-container 2>/dev/null
    echo "Neovim container removed"
}

dnvim-update() {
    docker pull mk1121/nvim:latest
    dnvim-remove
    echo "Container will be recreated on next dnvim run"
}
```

Reload and use:
```bash
source ~/.bashrc
dnvim myfile.txt
```

---

### Option B: Advanced Script with Auto-Mount

Create `~/bin/dnvim`:

```bash
#!/bin/bash

# dnvim - Persistent Docker Neovim with auto-mount
CONTAINER_NAME="nvim-container"
IMAGE="mk1121/nvim:latest"
CURRENT_DIR=$(pwd)

# Get container ID
CONTAINER_ID=$(docker ps -aqf "name=$CONTAINER_NAME")

# Function to create container
create_container() {
    echo "Creating persistent Neovim container..."
    docker run -itd \
        --name "$CONTAINER_NAME" \
        -v "$HOME:/host-home" \
        -v nvim-data:/root/.local/share/nvim \
        -v nvim-cache:/root/.cache/nvim \
        -e TERM=xterm-256color \
        --network=host \
        "$IMAGE" /bin/bash
}

# Create container if doesn't exist
if [ -z "$CONTAINER_ID" ]; then
    create_container
    CONTAINER_ID=$(docker ps -aqf "name=$CONTAINER_NAME")
fi

# Start container if stopped
if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER_ID" 2>/dev/null)" != "true" ]; then
    echo "Starting Neovim container..."
    docker start "$CONTAINER_ID" > /dev/null
fi

# Convert host path to container path
CONTAINER_PATH="${CURRENT_DIR/#$HOME//host-home}"

# Execute nvim with proper working directory
if [ $# -eq 0 ]; then
    # No arguments - open interactive shell in current directory
    docker exec -it -w "$CONTAINER_PATH" "$CONTAINER_ID" /bin/bash
else
    # Execute nvim with arguments
    docker exec -it -w "$CONTAINER_PATH" "$CONTAINER_ID" nvim "$@"
fi
```

Make executable and use:
```bash
chmod +x ~/bin/dnvim
export PATH="$HOME/bin:$PATH"
dnvim myfile.txt
```

---

## 🎮 Container Management Commands

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Get container ID by name
docker ps -aqf "name=nvim-container"

# Start container
docker start nvim-container

# Stop container
docker stop nvim-container

# Restart container
docker restart nvim-container

# Remove container
docker rm nvim-container

# View container logs
docker logs nvim-container

# Inspect container
docker inspect nvim-container

# Execute command in container
docker exec -it nvim-container nvim file.txt

# Open shell in container
docker exec -it nvim-container /bin/bash
```

---

## 📋 Usage Examples

### Basic Usage
```bash
dnvim file.txt                  # Edit file
dnvim file1.py file2.js        # Edit multiple files
dnvim .                         # Open file explorer
```

### Container Management
```bash
dnvim-shell                     # Open shell in container
dnvim-stop                      # Stop container
dnvim-restart                   # Restart container
dnvim-remove                    # Remove container
dnvim-update                    # Update image and recreate
```

### Direct Container Commands
```bash
# Using container ID
CONTAINER_ID=$(docker ps -aqf "name=nvim-container")
docker exec -it $CONTAINER_ID nvim file.txt

# Using container name
docker exec -it nvim-container nvim file.txt
```

---

## 🔧 Advanced Configurations

### 1. Multiple Project Containers

```bash
# Create container per project
dnvim-project() {
    local PROJECT_NAME=$(basename $(pwd))
    local CONTAINER_NAME="nvim-$PROJECT_NAME"
    
    if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        docker run -itd \
            --name "$CONTAINER_NAME" \
            -v "$(pwd):/workspace" \
            -v "nvim-${PROJECT_NAME}-data:/root/.local/share/nvim" \
            mk1121/nvim:latest /bin/bash
    fi
    
    docker start "$CONTAINER_NAME" 2>/dev/null
    docker exec -it -w /workspace "$CONTAINER_NAME" nvim "$@"
}
```

### 2. Shared Home Directory

```bash
# Mount entire home directory
docker run -itd \
    --name nvim-container \
    -v "$HOME:/home/user" \
    -e HOME=/home/user \
    -w /home/user \
    mk1121/nvim:latest /bin/bash
```

### 3. With Environment Variables

```bash
# Pass custom environment
docker exec -it \
    -e GIT_AUTHOR_NAME="Your Name" \
    -e GIT_AUTHOR_EMAIL="your@email.com" \
    nvim-container nvim
```

---

## 🚀 Performance Comparison

| Method | First Run | Subsequent Runs | Plugin Persistence |
|--------|-----------|-----------------|-------------------|
| `docker run --rm` | ~5s | ~5s | ❌ No |
| Persistent container | ~5s | <1s | ✅ Yes |

---

## 🐛 Troubleshooting

### Container not found
```bash
# Recreate container
docker rm nvim-container 2>/dev/null
docker run -itd --name nvim-container \
    -v $(pwd):/workspace \
    mk1121/nvim:latest /bin/bash
```

### Container stopped unexpectedly
```bash
# Check logs
docker logs nvim-container

# Restart
docker start nvim-container
```

### Can't access current directory
```bash
# Mount home directory
docker run -itd --name nvim-container \
    -v "$HOME:/home/user" \
    mk1121/nvim:latest /bin/bash
```

### Plugins not persisting
```bash
# Use named volumes
docker volume create nvim-data
docker volume create nvim-cache

docker run -itd --name nvim-container \
    -v nvim-data:/root/.local/share/nvim \
    -v nvim-cache:/root/.cache/nvim \
    mk1121/nvim:latest /bin/bash
```

---

## 🔄 Maintenance

### Backup Container Data
```bash
# Backup volumes
docker run --rm \
    -v nvim-data:/data \
    -v $(pwd):/backup \
    ubuntu tar czf /backup/nvim-backup.tar.gz /data
```

### Restore Container Data
```bash
# Restore volumes
docker run --rm \
    -v nvim-data:/data \
    -v $(pwd):/backup \
    ubuntu tar xzf /backup/nvim-backup.tar.gz -C /
```

### Clean Up Old Containers
```bash
# Remove all stopped containers
docker container prune

# Remove unused volumes
docker volume prune
```

---

## 💡 Pro Tips

1. **Use container names instead of IDs** for easier management
2. **Create volumes for plugin data** to persist across recreations
3. **Mount your home directory** for seamless file access
4. **Use docker-compose** for complex setups
5. **Keep container running** in the background for instant access

---

## 📚 Complete Setup Example

```bash
# 1. Create persistent container
docker run -itd \
    --name nvim-container \
    -v "$HOME:/host-home" \
    -v nvim-data:/root/.local/share/nvim \
    -v nvim-cache:/root/.cache/nvim \
    --network=host \
    mk1121/nvim:latest /bin/bash

# 2. Get container ID
CONTAINER_ID=$(docker ps -aqf "name=nvim-container")
echo "Container ID: $CONTAINER_ID"

# 3. Add to ~/.bashrc or ~/.zshrc
cat >> ~/.bashrc << 'EOF'
dnvim() {
    docker exec -it nvim-container \
        bash -c "cd /host-home${PWD/#$HOME} && nvim $*"
}
EOF

# 4. Reload shell
source ~/.bashrc

# 5. Use dnvim
cd ~/projects
dnvim myfile.py
```

---

**Last Updated**: 2025-11-10
**Version**: 1.0
**Maintainer**: mk1121
