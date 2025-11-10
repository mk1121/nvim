# Neovim Configuration

A modern, feature-rich Neovim configuration optimized for productivity and development.

## 📋 Requirements

### System Requirements
- **Neovim**: >= 0.10.0 (currently using v0.11.5)
- **Node.js**: >= 22.0.0 (v24.11.0 LTS recommended)
- **Git**: >= 2.0.0
- **Operating System**: Linux, macOS, or WSL2

### Required Dependencies

#### Core Tools
```bash
# Ubuntu/Debian
sudo apt install git curl wget unzip tar gzip ripgrep fd-find xclip

# Fedora/RHEL
sudo dnf install git curl wget unzip tar ripgrep fd-find xclip
```

#### Language Servers & Tools
```bash
# Node.js (via NVM - recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
nvm use --lts

# Python support
pip install pynvim --upgrade

# Additional build tools
sudo apt install build-essential
```

## 🚀 Installation

### Quick Install

```bash
# Backup your existing config (if any)
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup

# Clone this configuration
git clone https://github.com/mk1121/nvim-config.git ~/.config/nvim

# Start Neovim (plugins will auto-install)
nvim
```

### Post-Installation

1. **Install Language Servers**: Open Neovim and run `:Mason` to install LSP servers
2. **Authenticate Copilot**: Run `:Copilot auth` to enable GitHub Copilot
3. **Health Check**: Run `:checkhealth` to verify everything is working

## ⚡ Key Features

### Core Plugins

| Plugin | Purpose | Key Commands |
|--------|---------|--------------|
| **lazy.nvim** | Plugin manager | `:Lazy` |
| **nvim-lspconfig** | LSP configuration | `:LspInfo`, `:Mason` |
| **nvim-cmp** | Autocompletion | Auto-triggers on typing |
| **nvim-treesitter** | Syntax highlighting | `:TSUpdate` |
| **telescope.nvim** | Fuzzy finder | `<leader>ff`, `<leader>ft` |
| **which-key.nvim** | Keybinding hints | `<leader>` (shows menu) |
| **copilot.lua** | AI code completion | `:Copilot auth` |
| **gitsigns.nvim** | Git integration | `<leader>gj`, `<leader>gk` |

## ⌨️ Keybindings

### General
- `<leader>` = Space
- `<leader>e` = Toggle file explorer
- `<leader>ff` = Find files
- `<leader>ft` = Find text
- `<leader>la` = Code action
- `<leader>gj/gk` = Git next/prev hunk

## 🌟 Recent Updates

- ✅ Updated to Neovim v0.11.5
- ✅ Fixed which-key v3 API compatibility
- ✅ Fixed Copilot integration with nvim-cmp
- ✅ Updated Node.js to v24.11.0 LTS
- ✅ Fixed deprecated Vim API calls
- ✅ Updated Mason.nvim to v2.1.0

---

**Version**: 2024.11
**Last Updated**: 2025-11-10
**Maintainer**: mk1121
