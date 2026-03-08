function chead
    curl -sSD - $argv[1] -o /dev/null
end
