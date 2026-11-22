#!/usr/bin/env fish

set -l repo_root (path resolve (path dirname (status filename))/..)
set -l ghostty_config "$repo_root/ghostty/.config/ghostty/config"
set -l config_lines (string split \n -- (string collect <"$ghostty_config"))

for expected in \
        'keybind = performable:cmd+v=paste_from_clipboard' \
        'keybind = performable:cmd+key_v=paste_from_clipboard' \
        'keybind = ctrl+key_a>key_c=text:\x01c' \
        'keybind = ctrl+key_a>ctrl+key_a=text:\x01\x01' \
        'keybind = ctrl+key_a>key_r=text:\x01r' \
        'keybind = ctrl+key_a>key_h=text:\x01h' \
        'keybind = ctrl+key_a>key_j=text:\x01j' \
        'keybind = ctrl+key_a>key_k=text:\x01k' \
        'keybind = ctrl+key_a>key_l=text:\x01l' \
        'keybind = ctrl+key_a>key_v=text:\x01v' \
        'keybind = ctrl+key_a>key_n=text:\x01n' \
        'keybind = ctrl+key_a>key_p=text:\x01p' \
        'keybind = ctrl+key_a>key_d=text:\x01d' \
        'keybind = ctrl+key_a>key_m=text:\x01m' \
        'keybind = ctrl+key_a>key_w=text:\x01w' \
        'keybind = ctrl+key_a>key_g=text:\x01g' \
        'keybind = ctrl+key_a>key_b=text:\x01b' \
        'keybind = ctrl+key_a>key_s=text:\x01s' \
        'keybind = ctrl+key_a>key_o=text:\x01o' \
        'keybind = ctrl+key_a>key_e=text:\x01e' \
        'keybind = ctrl+key_a>key_x=text:\x01x' \
        'keybind = ctrl+key_a>comma=text:\x01,' \
        'keybind = ctrl+key_a>shift+slash=text:\x01?' \
        'keybind = ctrl+key_a>minus=text:\x01-' \
        'keybind = ctrl+key_a>shift+backslash=text:\x01|' \
        'keybind = ctrl+key_a>shift+key_h=text:\x01H' \
        'keybind = ctrl+key_a>shift+key_j=text:\x01J' \
        'keybind = ctrl+key_a>shift+key_k=text:\x01K' \
        'keybind = ctrl+key_a>shift+key_l=text:\x01L' \
        'keybind = ctrl+key_a>shift+key_r=text:\x01R' \
        'keybind = ctrl+key_a>shift+key_n=text:\x01N' \
        'keybind = ctrl+key_a>shift+key_g=text:\x01G' \
        'keybind = ctrl+key_a>shift+key_w=text:\x01W' \
        'keybind = ctrl+key_a>shift+key_d=text:\x01D' \
        'keybind = ctrl+key_a>shift+key_x=text:\x01X' \
        'keybind = ctrl+key_a>shift+key_p=text:\x01P' \
        'keybind = ctrl+key_a>alt+key_h=text:\x01\x1bh' \
        'keybind = ctrl+key_a>alt+key_j=text:\x01\x1bj' \
        'keybind = ctrl+key_a>alt+key_k=text:\x01\x1bk' \
        'keybind = ctrl+key_a>alt+key_l=text:\x01\x1bl'
    if not contains -- "$expected" $config_lines
        echo "Missing Ghostty Herdr/tmux keybind: $expected" >&2
        exit 1
    end
end

for number in (seq 1 9)
    set -l expected "keybind = ctrl+key_a>digit_$number=text:\\x01$number"
    if not contains -- "$expected" $config_lines
        echo "Missing Ghostty Herdr tab keybind: $expected" >&2
        exit 1
    end
end

if command -q ghostty
    ghostty +validate-config --config-file="$ghostty_config"
else if test -x /Applications/Ghostty.app/Contents/MacOS/ghostty
    /Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config --config-file="$ghostty_config"
end
