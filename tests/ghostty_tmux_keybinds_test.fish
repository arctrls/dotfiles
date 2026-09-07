#!/usr/bin/env fish

set -l repo_root (path resolve (path dirname (status filename))/..)
set -l ghostty_config "$repo_root/ghostty/.config/ghostty/config"
set -l config_contents (string collect <"$ghostty_config")

for expected in \
        'keybind = ctrl+key_a>key_c=text:\x01c' \
        'keybind = ctrl+key_a>ctrl+key_a=text:\x01\x01' \
        'keybind = ctrl+key_a>key_r=text:\x01r' \
        'keybind = ctrl+key_a>key_h=text:\x01h' \
        'keybind = ctrl+key_a>key_j=text:\x01j' \
        'keybind = ctrl+key_a>key_k=text:\x01k' \
        'keybind = ctrl+key_a>key_l=text:\x01l' \
        'keybind = ctrl+key_a>key_v=text:\x01v'
    if not string match --quiet "*$expected*" "$config_contents"
        echo "Missing Ghostty tmux keybind: $expected" >&2
        exit 1
    end
end

if command -q ghostty
    ghostty +validate-config --config-file="$ghostty_config"
end
