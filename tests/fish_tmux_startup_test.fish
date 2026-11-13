#!/usr/bin/env fish

set -l repo_root (path resolve (path dirname (status filename))/..)
set -l launcher "$repo_root/fish/.config/fish/functions/__start_multiplexer.fish"
set -l fish_bin (status fish-path)
set -l sandbox (mktemp -d)
mkdir "$sandbox/bin"

function cleanup --on-event fish_exit --inherit-variable sandbox
    rm -rf "$sandbox"
end

if not test -f "$launcher"
    echo "Missing multiplexer launcher: $launcher" >&2
    exit 1
end

printf '%s\n' '#!/bin/sh' 'echo "herdr $*" >> "$STARTUP_TEST_LOG"' 'if [ "$STARTUP_TEST_CHECK_COLOR" = 1 ]; then echo "NO_COLOR=${NO_COLOR-unset}" >> "$STARTUP_TEST_LOG"; fi' >"$sandbox/bin/herdr"
printf '%s\n' '#!/bin/sh' 'echo "tmux $*" >> "$STARTUP_TEST_LOG"' 'if [ "$1" = has-session ]; then exit "$STARTUP_TEST_HAS_SESSION"; fi' >"$sandbox/bin/tmux"
chmod +x "$sandbox/bin/herdr" "$sandbox/bin/tmux"

function check_startup --argument-names name expected interactive --inherit-variable sandbox --inherit-variable launcher --inherit-variable fish_bin
    printf '' >"$sandbox/log"
    set -l mode -c
    if test "$interactive" = yes
        set mode -ic
    end
    env -u TMUX -u HERDR_ENV -u HERDR_PANE_ID -u HERDR_ACTIVE_PANE_ID \
        PATH="$sandbox/bin:/usr/bin:/bin" STARTUP_TEST_LOG="$sandbox/log" \
        STARTUP_TEST_HAS_SESSION=0 $argv[4..] \
        "$fish_bin" --no-config $mode 'source $argv[1]; __start_multiplexer; if test "$STARTUP_TEST_CHECK_COLOR" = 1; set -l color unset; if set -q NO_COLOR; set color "$NO_COLOR"; end; printf "NO_COLOR=%s\n" "$color" >> "$STARTUP_TEST_LOG"; end' "$launcher"
    or exit 1
    set -l actual (string join '|' (cat "$sandbox/log"))
    if test "$actual" != "$expected"
        echo "$name: expected '$expected', got '$actual'" >&2
        exit 1
    end
    echo "PASS: $name"
end

check_startup 'prefer Herdr' 'herdr ' yes
check_startup 'non-interactive shell' '' no
check_startup 'existing tmux pane' '' yes TMUX=test
check_startup 'existing Herdr shell' '' yes HERDR_ENV=1
check_startup 'existing Herdr pane' '' yes HERDR_PANE_ID=w1:p1
check_startup 'Herdr popup shell' '' yes HERDR_ACTIVE_PANE_ID=w1:p1
check_startup 'new Herdr server keeps colors' 'herdr |NO_COLOR=unset' yes NO_COLOR=1 STARTUP_TEST_CHECK_COLOR=1
check_startup 'existing Herdr server does not disable shell colors' 'NO_COLOR=unset' yes HERDR_ENV=1 NO_COLOR=1 STARTUP_TEST_CHECK_COLOR=1
check_startup 'non-interactive shell preserves NO_COLOR' 'NO_COLOR=1' no HERDR_ENV=1 NO_COLOR=1 STARTUP_TEST_CHECK_COLOR=1
check_startup 'tmux shell preserves NO_COLOR' 'NO_COLOR=1' yes TMUX=test NO_COLOR=1 STARTUP_TEST_CHECK_COLOR=1
rm "$sandbox/bin/herdr"
check_startup 'fallback attaches tmux' 'tmux has-session|tmux attach' yes
check_startup 'fallback creates tmux' 'tmux has-session|tmux new' yes STARTUP_TEST_HAS_SESSION=1
rm "$sandbox/bin/tmux"
check_startup 'no multiplexer installed' '' yes
