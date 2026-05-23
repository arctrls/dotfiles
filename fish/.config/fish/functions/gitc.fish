function gitc --description 'Check out a remote branch as a local tracking branch'
    if test (count $argv) -eq 0
        echo "usage: gitc <branch>|<remote>/<branch> [branch]" >&2
        return 2
    end

    set -l remote_branch
    if test (count $argv) -eq 1
        if string match -q '*/*' -- $argv[1]
            set remote_branch $argv[1]
        else
            set remote_branch origin/$argv[1]
        end
    else
        set remote_branch $argv[1]/$argv[2]
    end

    git switch --track $remote_branch
end
