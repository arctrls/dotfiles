#!/usr/bin/env fish

set -l repo_root (path resolve (path dirname (status filename))/..)
set -l ghostty_config "$repo_root/ghostty/.config/ghostty/config"
set -l config_contents (string collect <"$ghostty_config")

for expected in \
        'keybind = ctrl+a>c=text:\x01c' \
        'keybind = ctrl+a>ctrl+a=text:\x01\x01' \
        'keybind = ctrl+a>r=text:\x01r' \
        'keybind = ctrl+a>h=text:\x01h' \
        'keybind = ctrl+a>j=text:\x01j' \
        'keybind = ctrl+a>k=text:\x01k' \
        'keybind = ctrl+a>l=text:\x01l' \
        'keybind = ctrl+a>v=text:\x01v'
    if not string match --quiet "*$expected*" "$config_contents"
        echo "Missing Ghostty tmux keybind: $expected" >&2
        exit 1
    end
end

if command -q ghostty
    ghostty +validate-config --config-file="$ghostty_config"
end
