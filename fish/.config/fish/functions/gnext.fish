function gnext
    set -l branch main
    if test (count $argv) -gt 0
        set branch $argv[1]
    end

    git checkout .
    git clean -fd
    git checkout (git log --reverse --pretty=%H --ancestry-path HEAD..$branch | head -n 1)
end
