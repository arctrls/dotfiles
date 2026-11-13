function __start_multiplexer --description 'Start Herdr once, with tmux as a fallback'
    if not status is-interactive
        return
    end
    if set -q TMUX; or set -q HERDR_ENV; or set -q HERDR_PANE_ID; or set -q HERDR_ACTIVE_PANE_ID
        return
    end

    if command -q herdr
        exec herdr
    else if command -q tmux
        if tmux has-session 2>/dev/null
            exec tmux attach
        else
            exec tmux new
        end
    end
end
