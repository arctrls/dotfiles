#!/usr/bin/env fish

set -l repo_root (path resolve (path dirname (status filename))/..)
set -l init_file "$repo_root/fish/.config/omf/init.fish"
set -l init_contents (string collect <"$init_file")

for expected in \
        'if status is-interactive' \
        'if not set -q TMUX' \
        'if command -q tmux' \
        'if tmux has-session 2>/dev/null' \
        'exec tmux attach' \
        'exec tmux new'
    if not string match --quiet "*$expected*" "$init_contents"
        echo "Missing tmux startup behavior: $expected" >&2
        exit 1
    end
end
