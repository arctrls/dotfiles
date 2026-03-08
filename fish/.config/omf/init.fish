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
            tmux attach; or tmux new
        end
    end
end
