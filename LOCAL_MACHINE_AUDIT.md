# Local Machine Audit

Generated on 2026-03-10.

This document captures machine-local settings and external dependencies that affect this dotfiles repository but are not fully reproduced by the repository alone.

The purpose is practical: if another machine applies only this repository, the final environment will still differ unless the external pieces documented here are also recreated.

## Scope

This audit covers settings that affect the tools managed by this repository:

- fish
- Oh My Fish (OMF)
- zsh
- Oh My Zsh
- tmux
- Neovim
- Ghostty
- skhd
- Karabiner
- Homebrew-installed tools and fonts that these configs assume

This audit does **not** attempt to capture every macOS GUI preference, Keychain item, application database, or secret value. Secret values are intentionally redacted.

## High-level Findings

The main sources of drift are:

1. `fish` is only partially represented by this repo.
   - Repo-managed files are linked in.
   - There are additional local files under `~/.config/fish` and `~/.config/omf`.
   - The actual prompt implementation lives outside the repo in the OMF installation directory.
   - One fish file comes from another repository: `~/projects/dotfiles-secrets`.

2. `zsh` depends on external state.
   - `~/.zshrc` is repo-managed.
   - `~/.oh-my-zsh` is an external install.
   - `~/.zshrc.local` comes from `~/projects/dotfiles-secrets` and loads a private env file.

3. `tmux` depends on an external plugin checkout.
   - The repo contains `.tmux.conf`.
   - The config directly executes `~/.config/tmux/plugins/catppuccin/tmux/catppuccin.tmux`.

4. `nvim` depends heavily on runtime state outside the repo.
   - The repo contains the config.
   - Plugins, Mason packages, caches, logs, session state, undo history, and parser installs live under `~/.local/share/nvim`, `~/.local/state/nvim`, and `~/.cache/nvim`.
   - This machine also contains old `LazyVim` artifacts that are not driven by the current repo.

5. `ghostty`, `karabiner`, `skhd`, `tmux`, and `zsh` are stowed cleanly enough at the target path level, but the programs they depend on still must be installed separately.

## System Baseline

```text
ProductName:        macOS
ProductVersion:     26.3.1
BuildVersion:       25D2128
Hostname:           Mac.T-mobile.com

fish:               4.5.0
stow:               2.4.1
zsh:                5.9 (arm64-apple-darwin25.0)
nvim:               0.11.6
ghostty:            1.2.3
skhd:               0.3.9
brew:               5.0.16
```

## Stow / Target Mapping Snapshot

| Component | Repo source | Actual target | Target shape | Current status |
| --- | --- | --- | --- | --- |
| fish | `fish/.config/fish/**` | `~/.config/fish` | real directory with mixed contents | partial stow + local extras |
| OMF config | `fish/.config/omf/**` | `~/.config/omf` | real directory with mixed contents | partial stow + local extras |
| ghostty | `ghostty/.config/ghostty/**` | `~/.config/ghostty` | directory symlink | clean |
| karabiner | `karabiner/.config/karabiner/**` | `~/.config/karabiner` | directory symlink | clean |
| nvim | `nvim/.config/nvim/**` | `~/.config/nvim` | directory symlink | clean |
| skhd | `skhd/.skhdrc` | `~/.skhdrc` | file symlink | clean |
| tmux | `tmux/.tmux.conf` | `~/.tmux.conf` | file symlink | clean |
| zsh | `zsh/.zshrc` | `~/.zshrc` | file symlink | clean |

### Link status details

```text
~/.config/fish/conf.d/autopair.fish -> ../../../projects/dotfiles/fish/.config/fish/conf.d/autopair.fish
~/.config/fish/conf.d/omf.fish -> ../../../projects/dotfiles/fish/.config/fish/conf.d/omf.fish
~/.config/fish/conf.d/private-env.fish -> ../../../projects/dotfiles-secrets/fish/.config/fish/conf.d/private-env.fish
~/.config/fish/functions -> ../../projects/dotfiles/fish/.config/fish/functions
~/.config/fish/config.fish -> regular file
~/.config/fish/fish_variables -> regular file

~/.config/omf/bundle -> ../../projects/dotfiles/fish/.config/omf/bundle
~/.config/omf/init.fish -> ../../projects/dotfiles/fish/.config/omf/init.fish
~/.config/omf/theme -> ../../projects/dotfiles/fish/.config/omf/theme
~/.config/omf/channel -> regular file

~/.config/ghostty -> ../projects/dotfiles/ghostty/.config/ghostty
~/.config/karabiner -> ../projects/dotfiles/karabiner/.config/karabiner
~/.config/nvim -> ../projects/dotfiles/nvim/.config/nvim
~/.skhdrc -> projects/dotfiles/skhd/.skhdrc
~/.tmux.conf -> projects/dotfiles/tmux/.tmux.conf
~/.zshrc -> projects/dotfiles/zsh/.zshrc
```

## Fish + OMF Audit

### Why fish differs from repo-only state

The repo contains the fish loader and the OMF config selector, but the live prompt is implemented by an external OMF install.

Repo-managed fish/OMF files:

- `fish/.config/fish/conf.d/omf.fish`
- `fish/.config/omf/bundle`
- `fish/.config/omf/theme`
- `fish/.config/omf/init.fish`
- `fish/.config/fish/functions/**`
- `fish/.config/fish/conf.d/autopair.fish`

Machine-local additions outside this repo:

- `~/.config/fish/config.fish`
- `~/.config/fish/fish_variables`
- `~/.config/omf/channel`
- `~/.config/fish/conf.d/private-env.fish` from `~/projects/dotfiles-secrets`
- `~/.config/shell/private.env` secret file
- `~/.local/share/omf/**` actual OMF installation and default theme implementation

### Repo-managed fish/OMF content

`fish/.config/fish/conf.d/omf.fish`

```fish
# Path to Oh My Fish install.
set -q XDG_DATA_HOME
    and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
    or set -gx OMF_PATH "$HOME/.local/share/omf"

# Load Oh My Fish configuration.
if test -f "$OMF_PATH/init.fish"
    source "$OMF_PATH/init.fish"
end
```

`fish/.config/omf/bundle`

```text
theme default
```

`fish/.config/omf/theme`

```text
default
```

`fish/.config/omf/init.fish`

```fish
set -gx ENABLE_LSP_TOOL 1
set -gx HOMEBREW_AUTO_UPDATE_SECS 1
set -e HOMEBREW_NO_AUTO_UPDATE
set -gx HOMEBREW_NO_ENV_HINTS 1
set -gx BUN_INSTALL "$HOME/.bun"
set -gx PYENV_ROOT "$HOME/.pyenv"
set -gx FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -gx FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"

fish_add_path "$BUN_INSTALL/bin"
fish_add_path "$PYENV_ROOT/bin" "$PYENV_ROOT/shims"
fish_add_path "$HOME/.jenv/bin" "$HOME/.jenv/shims"
fish_add_path "$HOME/.local/bin"
fish_add_path /opt/homebrew/opt/mysql-client/bin

if command -q fnm
    fnm env --shell fish --use-on-cd --version-file-strategy=recursive --corepack-enabled | source
end

if command -q zoxide
    zoxide init fish | source
end

if command -q fzf
    fzf --fish | source
end

if command -q kubectl
    kubectl completion fish | source
end

alias vi='nvim'
alias vim='nvim'
alias ll='eza --long --git --all'
alias gitr='git reset --hard HEAD && git clean -fd'
alias cl='claude --dangerously-skip-permissions'
alias cx='omx --xhigh --madmax'
alias cat='bat --paging=never'

if status is-interactive
    if not set -q TMUX
        if command -q tmux
            if tmux has-session 2>/dev/null
                exec tmux attach
            else
                exec tmux new
            end
        end
    end
end
```

### Local-only fish/OMF files

`~/.config/fish/config.fish`

```fish
if status is-interactive
# Commands to run in interactive sessions can go here
end
```

`~/.config/fish/conf.d/private-env.fish`

This file is **not** in this repo. It is symlinked from `~/projects/dotfiles-secrets/fish/.config/fish/conf.d/private-env.fish`.

```fish
set -l private_env_file "$HOME/.config/shell/private.env"

if test -f "$private_env_file"
    while read -l line
        set line (string trim -- "$line")

        if test -z "$line"
            continue
        end

        if string match -qr '^#' -- "$line"
            continue
        end

        set -l parts (string split -m 1 '=' -- "$line")
        if test (count $parts) -ne 2
            continue
        end

        set -l key (string trim -- "$parts[1]")
        set -l value (string trim -- "$parts[2]")

        if string match -qr '^".*"$' -- "$value"
            set value (string sub -s 2 -e -1 -- "$value")
        else if test (string sub -s 1 -l 1 -- "$value") = "'"; and test (string sub -s -1 -l 1 -- "$value") = "'"
            set value (string sub -s 2 -e -1 -- "$value")
        end

        set -gx $key "$value"
    end < "$private_env_file"
end
```

`~/.config/fish/fish_variables`

```text
# This file contains fish universal variable definitions.
# VERSION: 3.0
SETUVAR __fish_initialized:4300
SETUVAR fish_user_paths:/Users/jazzbach/\.local/bin\x1e/Users/jazzbach/\.jenv/shims\x1e/Users/jazzbach/\.pyenv/shims\x1e/Users/jazzbach/\.bun/bin
```

`~/.config/omf/channel`

```text
stable
```

`~/.config/shell/private.env`

- Exists as a regular file.
- It is **not** symlinked.
- It is consumed by both fish and zsh local secret loaders.
- Captured key names only, values intentionally redacted:

```text
JIRA_API_TOKEN
NOTION_TOKEN
GITHUB_PERSONAL_ACCESS_TOKEN
DD_API_KEY
DD_APP_KEY
DATABASE_WRITER_ENDPOINT
DATABASE_READER_ENDPOINT
DATASOURCE_USERNAME
```

### External OMF installation

OMF runtime paths:

```text
OMF_PATH=/Users/jazzbach/.local/share/omf
OMF_CONFIG=/Users/jazzbach/.config/omf
```

External OMF git checkout:

```text
path:   ~/.local/share/omf
remote: https://github.com/oh-my-fish/oh-my-fish.git
commit: 92a572d8cdfdf5b219269d59210b8a28f6cd6616
```

Actual live prompt origin:

```text
fish_prompt is defined in ~/.local/share/omf/themes/default/functions/fish_prompt.fish
```

Prompt-related variables were checked and are currently unset:

```text
theme_short_path: UNSET
theme_stash_indicator: UNSET
theme_ignore_ssh_awareness: UNSET
```

### Live prompt implementation outside the repo

`~/.local/share/omf/themes/default/functions/fish_prompt.fish`

```fish
# You can override some default options with config.fish:
#
#  set -g theme_short_path yes
#  set -g theme_stash_indicator yes
#  set -g theme_ignore_ssh_awareness yes

function fish_prompt
  set -l last_command_status $status
  set -l cwd

  if test "$theme_short_path" = 'yes'
    set cwd (basename (prompt_pwd))
  else
    set cwd (prompt_pwd)
  end

  set -l fish     "⋊>"
  set -l ahead    "↑"
  set -l behind   "↓"
  set -l diverged "⥄"
  set -l dirty    "⨯"
  set -l stash    "≡"
  set -l none     "◦"

  set -l normal_color     (set_color normal)
  set -l success_color    (set_color cyan)
  set -l error_color      (set_color $fish_color_error 2> /dev/null; or set_color red --bold)
  set -l directory_color  (set_color $fish_color_quote 2> /dev/null; or set_color brown)
  set -l repository_color (set_color $fish_color_cwd 2> /dev/null; or set_color green)

  set -l prompt_string $fish

  if test "$theme_ignore_ssh_awareness" != 'yes' -a -n "$SSH_CLIENT$SSH_TTY"
    set prompt_string "$fish "(whoami)"@"(hostname -s)" $fish"
  end

  if test $last_command_status -eq 0
    echo -n -s $success_color $prompt_string $normal_color
  else
    echo -n -s $error_color $prompt_string $normal_color
  end

  if git_is_repo
    if test "$theme_short_path" = 'yes'
      set root_folder (command git rev-parse --show-toplevel 2> /dev/null)
      set parent_root_folder (dirname $root_folder)
      set cwd (echo $PWD | sed -e "s|$parent_root_folder/||")
    end

    echo -n -s " " $directory_color $cwd $normal_color
    echo -n -s " on " $repository_color (git_branch_name) $normal_color " "

    set -l list
    if test "$theme_stash_indicator" = yes; and git_is_stashed
      set list $list $stash
    end
    if git_is_touched
      set list $list $dirty
    end
    echo -n $list

    if test -z "$list"
      echo -n -s (git_ahead $ahead $behind $diverged $none)
    end
  else
    echo -n -s " " $directory_color $cwd $normal_color
  end

  echo -n -s " "
end
```

`~/.local/share/omf/themes/default/functions/fish_right_prompt.fish`

```fish
function fish_right_prompt
  set_color $fish_color_autosuggestion 2> /dev/null; or set_color 555
  date "+%H:%M:%S"
  set_color normal
end
```

### Fish reproducibility implications

To reproduce fish exactly on another machine, this repo alone is insufficient. You also need:

- a compatible OMF install under `~/.local/share/omf`
- the same or equivalent OMF commit
- `~/.config/omf/channel`
- the secret-side fish loader from `~/projects/dotfiles-secrets`
- `~/.config/shell/private.env`
- the same fish universal variables, if path ordering matters

## Zsh Audit

### Repo-managed zsh config

`~/.zshrc` is symlinked to this repo and does not differ from the repo copy.

Important external references inside the repo-managed `zsh/.zshrc`:

- `export ZSH="$HOME/.oh-my-zsh"`
- `ZSH_THEME="robbyrussell"`
- `plugins=(git kubectl)`
- `[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"`
- `[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local`
- `eval "$(fzf --zsh)"`
- `eval "$(fnm env --shell zsh ...)"`
- `eval "$(pyenv init --path)"`
- `eval "$(pyenv init -)"`
- `eval "$(zoxide init zsh)"`
- `export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"`

### External Oh My Zsh installation

```text
path:   ~/.oh-my-zsh
remote: https://github.com/ohmyzsh/ohmyzsh.git
commit: 5c4f27b7166360bd23709f24642b247eac30a147
```

### Local secret zsh file

`~/.zshrc.local` exists as a symlink to another repository:

```text
~/.zshrc.local -> projects/dotfiles-secrets/zsh/.zshrc.local
```

Contents:

```zsh
# Load private credentials from the shared env file.
PRIVATE_ENV_FILE="$HOME/.config/shell/private.env"

if [[ -f "$PRIVATE_ENV_FILE" ]]; then
  set -a
  source "$PRIVATE_ENV_FILE"
  set +a
fi
```

### Zsh reproducibility implications

To reproduce zsh exactly on another machine, this repo alone is insufficient. You also need:

- `~/.oh-my-zsh`
- `~/.zshrc.local` or an equivalent secrets-side loader
- `~/.config/shell/private.env`
- installed binaries expected by `.zshrc` such as `jenv`, `kubectl`, `fzf`, `fnm`, `pyenv`, `zoxide`, `bat`, `tmux`, `eza`

## Tmux Audit

`~/.tmux.conf` is symlinked to this repo and matches the repo copy.

Important external dependency in `.tmux.conf`:

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @catppuccin_flavor "latte"
run ~/.config/tmux/plugins/catppuccin/tmux/catppuccin.tmux
```

External plugin checkout detected:

```text
path:   ~/.config/tmux/plugins/catppuccin/tmux
remote: https://github.com/catppuccin/tmux.git
commit: b2f219c00609ea1772bcfbdae0697807184743e4
```

Observed tmux plugin/state directories:

```text
~/.config/tmux/plugins/catppuccin/tmux exists
~/.tmux does not exist
~/.tmux/plugins does not exist
~/.local/share/tmux does not exist
```

### Tmux reproducibility implications

To reproduce tmux exactly on another machine, this repo alone is insufficient. You also need:

- the catppuccin tmux plugin checkout at `~/.config/tmux/plugins/catppuccin/tmux`
- a compatible `fish` binary at `/opt/homebrew/bin/fish`, because `.tmux.conf` sets `default-shell` and `default-command` to that path

## Neovim Audit

`~/.config/nvim` is a directory symlink to this repo and matches the repo copy.

The repo config intentionally installs and manages runtime state outside the repo.

### Repo-side plugin/LSP/formatter behavior

`nvim/.config/nvim/init.lua`

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"

if not vim.uv.fs_stat(mini_path) then
  vim.cmd('echo "Installing mini.nvim" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/echasnovski/mini.nvim",
    mini_path,
  }
  vim.fn.system(clone_cmd)
  if vim.v.shell_error ~= 0 then
    error("Failed to install mini.nvim")
  end
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd('echo "Installed mini.nvim" | redraw')
end

require("mini.deps").setup({ path = { package = path_package } })

require("config.options")
require("config.keymaps")
require("config.plugins")
require("config.statusline")
require("config.completion")
require("config.lsp")
require("config.format")
```

`nvim/.config/nvim/lua/config/plugins.lua`

```lua
local add = MiniDeps.add

add("scottmckendry/cyberdream.nvim")
add("iamcco/markdown-preview.nvim")
add("lewis6991/gitsigns.nvim")
add("mason-org/mason.nvim")
add("mason-org/mason-lspconfig.nvim")
add("neovim/nvim-lspconfig")
add({
  source = "nvim-treesitter/nvim-treesitter",
  hooks = {
    post_checkout = function()
      pcall(vim.cmd, "TSUpdate")
    end,
  },
})
add("saghen/blink.cmp")
add("stevearc/conform.nvim")

vim.g.mkdp_auto_start = 0
vim.g.mkdp_filetypes = { "markdown" }

local markdown_preview_root = vim.fn.stdpath("data") .. "/site/pack/deps/opt/markdown-preview.nvim"
local markdown_preview_app = markdown_preview_root .. "/app"
if vim.uv.fs_stat(markdown_preview_root) then
  vim.cmd("packadd markdown-preview.nvim")
end
if vim.uv.fs_stat(markdown_preview_app) and not vim.uv.fs_stat(markdown_preview_app .. "/node_modules") then
  local out = vim.fn.system({
    "sh",
    "-c",
    "cd " .. vim.fn.shellescape(markdown_preview_app) .. " && npm install",
  })
  if vim.v.shell_error ~= 0 then
    vim.notify("markdown-preview.nvim install failed:\n" .. out, vim.log.levels.ERROR)
  end
end

local treesitter_parsers = {
  "bash",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "query",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
  "zsh",
}

local treesitter_languages = {
  bash = { "bash", "sh" },
  json = { "json", "jsonc" },
  lua = { "lua" },
  markdown = { "markdown" },
  query = { "query" },
  toml = { "toml" },
  vim = { "vim" },
  vimdoc = { "help" },
  yaml = { "yaml" },
  zsh = { "zsh" },
}

local treesitter = require("nvim-treesitter")

treesitter.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

treesitter.install(treesitter_parsers)

for lang, filetypes in pairs(treesitter_languages) do
  for _, filetype in ipairs(filetypes) do
    vim.treesitter.language.register(lang, filetype)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "bash",
    "help",
    "json",
    "jsonc",
    "lua",
    "markdown",
    "query",
    "sh",
    "toml",
    "vim",
    "yaml",
    "zsh",
  },
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

require("gitsigns").setup({
  signs = {
    add = { text = "┃" },
    change = { text = "┃" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,
  current_line_blame = false,
})

require("cyberdream").setup({
  variant = "light",
  overrides = function(colors)
    return {
      CursorLine = { bg = "#f5f5f5" },
      CursorLineNr = { fg = colors.fg, bg = "#f5f5f5", bold = true },
      Visual = { bg = "#b4d5fe" },
      VisualNOS = { bg = "#b4d5fe" },
      Search = { bg = "#ffd33d" },
      IncSearch = { bg = "#ffd33d" },
    }
  end,
})

vim.cmd.colorscheme("cyberdream")
```

`nvim/.config/nvim/lua/config/lsp.lua`

```lua
local capabilities = require("blink.cmp").get_lsp_capabilities()

local servers = {
  bashls = {},
  jsonls = {},
  lua_ls = {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath("config")
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
        runtime = {
          version = "LuaJIT",
          path = {
            "lua/?.lua",
            "lua/?/init.lua",
          },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      })
    end,
    settings = {
      Lua = {},
    },
  },
  marksman = {},
  taplo = {},
}

for server, config in pairs(servers) do
  config.capabilities = capabilities
  vim.lsp.config(server, config)
end

require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_enable = true,
})

local function ensure_tools_installed(tools)
  local registry = require("mason-registry")

  registry.refresh(function()
    for _, tool in ipairs(tools) do
      local ok, pkg = pcall(registry.get_package, tool)
      if ok and not pkg:is_installed() then
        pkg:install()
      end
    end
  end)
end

ensure_tools_installed({
  "prettier",
  "shfmt",
  "stylua",
  "taplo",
})
```

`nvim/.config/nvim/lua/config/format.lua`

```lua
local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    json = { "prettier" },
    jsonc = { "prettier" },
    lua = { "stylua" },
    markdown = { "prettier" },
    sh = { "shfmt" },
    toml = { "taplo" },
    yaml = { "prettier" },
    zsh = { "shfmt" },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
  format_on_save = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },
})

vim.api.nvim_create_user_command("Format", function()
  conform.format({ async = false, lsp_format = "fallback" })
end, { desc = "Format current buffer" })
```

### External Neovim runtime state on this machine

Observed runtime directories:

```text
~/.local/share/nvim exists
~/.local/state/nvim exists
~/.cache/nvim exists
```

Notable runtime contents detected under `~/.local/share/nvim`:

```text
site/pack                # mini.deps package area
lazy/                    # plugin checkouts
mason/                   # LSP/formatter registry and installs
blink/                   # blink runtime data
snacks/                  # picker history + sqlite DB
```

Notable installed plugin directories detected:

```text
LazyVim
SchemaStore.nvim
blink.cmp
conform.nvim
gitsigns.nvim
lazy.nvim
mason.nvim
mason-lspconfig.nvim
mini.ai
mini.icons
mini.pairs
nvim-lspconfig
nvim-treesitter
render-markdown.nvim
snacks.nvim
tokyonight.nvim
which-key.nvim
```

Important observation:

- `LazyVim` artifacts exist in `~/.local/share/nvim/lazy/LazyVim` and also in `~/.cache/nvim/luac/...LazyVim...`.
- The current repo config does **not** use LazyVim.
- These are almost certainly leftovers from an older Neovim setup on this machine.
- They may not be active, but they are still part of the machine-local state and can confuse comparisons.

Additional local state detected under `~/.local/state/nvim`:

```text
conform.log
lsp.log
mason.log
sessions/
shada/
swap/
undo/
lazy/state.json
```

### Neovim reproducibility implications

To reproduce Neovim exactly on another machine, this repo alone is insufficient. You also need:

- plugin installs to be re-created under `~/.local/share/nvim`
- Mason tool installs to be re-created under `~/.local/share/nvim/mason`
- Node/npm available for `markdown-preview.nvim`
- treesitter parser installations under the Neovim data dir
- optionally, a cleanup step for old runtime artifacts like `LazyVim`, if you want a clean comparison baseline

## Ghostty Audit

`~/.config/ghostty` is a directory symlink to this repo and no local-only diff was detected under the target path.

Important repo settings that still require machine-local resources:

```ini
font-family = "JetBrainsMono Nerd Font"
font-family = "Apple SD Gothic Neo"
theme = "iTerm2 Light Background"
font-size = 14
shell-integration-features = no-cursor, sudo,no-title
```

Reproducibility notes:

- `JetBrainsMono Nerd Font` must be installed.
- `Apple SD Gothic Neo` is macOS-provided.
- `ghostty` itself must be installed.

## Skhd Audit

`~/.skhdrc` is symlinked to this repo and no diff was detected.

The shortcuts depend on machine-local application install names:

```text
Google Chrome Canary
Obsidian
Ghostty
Finder
Things3
IntelliJ IDEA
Slack
Microsoft Teams
```

If those app names differ on another machine, the bindings will not behave the same way.

## Karabiner Audit

`~/.config/karabiner` is a directory symlink to this repo and no local-only diff was detected under the target path.

Even with the repo present, the following still matter outside the repo:

- Karabiner-Elements app installation
- macOS accessibility/input permissions
- any separate Karabiner application state outside the linked config tree

## Homebrew / Installation Audit

The repo already contains `Brewfile`, but this machine also relies on additional install steps and external git/curl installations.

Repo-captured package manager state:

- `fish`
- `fnm`
- `fzf`
- `jenv`
- `pyenv`
- `zoxide`
- `tmux`
- `stow`
- `neovim`
- `ghostty`
- `skhd`
- `font-jetbrains-mono-nerd-font`

Additional external installations **not** fully version-pinned by this repo:

- Oh My Fish under `~/.local/share/omf`
- Oh My Zsh under `~/.oh-my-zsh`
- tmux catppuccin plugin under `~/.config/tmux/plugins/catppuccin/tmux`
- `~/projects/dotfiles-secrets`
- `~/.config/shell/private.env`

The repo `README.md` already acknowledges that shell frameworks are installed separately, but it does not pin exact external commits.

## What Another Machine Needs To Match This One

To get meaningfully close to the current machine, another machine needs all of the following in addition to this repo:

1. The repo itself, applied with GNU Stow.
2. Homebrew formulas/casks from `Brewfile`.
3. OMF installed under `~/.local/share/omf`, ideally at commit `92a572d8cdfdf5b219269d59210b8a28f6cd6616`.
4. Oh My Zsh installed under `~/.oh-my-zsh`, ideally at commit `5c4f27b7166360bd23709f24642b247eac30a147`.
5. The tmux catppuccin plugin checkout at commit `b2f219c00609ea1772bcfbdae0697807184743e4`.
6. The separate `dotfiles-secrets` repository, because fish and zsh both reference it.
7. The secret env file at `~/.config/shell/private.env`.
8. Neovim runtime plugin/tool installs under `~/.local/share/nvim`.
9. Matching fonts and application names for Ghostty and skhd.
10. A decision on whether to preserve or delete old machine-local Neovim artifacts such as `LazyVim` leftovers.

## Suggested Follow-up Work

If the goal is to reduce drift between machines, the highest-impact improvements would be:

1. Vendor or pin the fish prompt implementation instead of depending on the live OMF default theme directory.
2. Decide whether `~/.config/fish/config.fish`, `~/.config/fish/fish_variables`, and `~/.config/omf/channel` should be explicitly managed.
3. Move non-secret loader files from `dotfiles-secrets` into this repo where possible, and keep only the actual secret values outside.
4. Pin external git-based installs in documentation or bootstrap scripts.
5. Add a bootstrap script that installs OMF, Oh My Zsh, tmux plugins, and a clean Neovim runtime baseline.
6. Clean stale Neovim artifacts from older setups before comparing machines.
