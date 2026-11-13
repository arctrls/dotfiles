function __start_multiplexer --description 'Start Herdr once, with tmux as a fallback'
    if not status is-interactive
        return
    end
    if set -q HERDR_ENV; or set -q HERDR_PANE_ID; or set -q HERDR_ACTIVE_PANE_ID
        # Persistent servers may inherit NO_COLOR from an agent's tool environment.
        set -eg NO_COLOR
        return
    end
    if set -q TMUX
        return
    end

    if command -q herdr
        exec env -u NO_COLOR herdr
    else if command -q tmux
        if tmux has-session 2>/dev/null
            exec tmux attach
        else
            exec tmux new
        end
    end
end
