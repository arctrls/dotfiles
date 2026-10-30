function fish_right_prompt --description 'Show the current Kubernetes context'
    if contains -- --final-rendering $argv
        return
    end

    command -q kubectl; or return
    set -l context (command kubectl config current-context 2>/dev/null)
    if test -n "$context"
        set_color magenta
        printf '%s' "$context"
        set_color --reset
    end
end
