# Fish OMF Prompt Reproduction

The goal is to make the `fish` prompt on another machine match this machine as closely as possible.

This project does not vendor the `fish` prompt implementation itself. It manages the OMF selectors and initialization code, while the actual prompt shape is determined by the local OMF installation.

## Repo-managed baseline

These files are already managed in this repository:

- `fish/.config/fish/conf.d/omf.fish`
- `fish/.config/omf/bundle`
- `fish/.config/omf/theme`
- `fish/.config/omf/init.fish`

Current baseline values:

- OMF theme: `default`
- OMF bundle: `theme default`
- OMF channel: `stable`

## Actual prompt source on this machine

On this machine, the live prompt is loaded from the local OMF install, not from this repo.

- OMF path: `~/.local/share/omf`
- OMF remote: `https://github.com/oh-my-fish/oh-my-fish.git`
- OMF commit: `92a572d8cdfdf5b219269d59210b8a28f6cd6616`
- Prompt source: `~/.local/share/omf/themes/default/functions/fish_prompt.fish`
- Right prompt source: `~/.local/share/omf/themes/default/functions/fish_right_prompt.fish`

Current prompt-related variable state:

- `theme_short_path`: unset
- `theme_stash_indicator`: unset
- `theme_ignore_ssh_awareness`: unset

The current `~/.config/fish/config.fish` does not override the prompt.

## What must match on another machine

If the prompt looks different on another machine, check these first.

1. `fish/.config/omf/theme` is `default`
2. `fish/.config/omf/bundle` contains `theme default`
3. `~/.config/omf/channel` is `stable`
4. `~/.local/share/omf` is installed
5. `~/.local/share/omf` is at commit `92a572d8cdfdf5b219269d59210b8a28f6cd6616`
6. `functions fish_prompt` resolves to `~/.local/share/omf/themes/default/functions/fish_prompt.fish`
7. `functions fish_right_prompt` resolves to `~/.local/share/omf/themes/default/functions/fish_right_prompt.fish`
8. `theme_short_path`, `theme_stash_indicator`, and `theme_ignore_ssh_awareness` are unset
9. `~/.config/fish/config.fish` does not redefine `fish_prompt` or `fish_right_prompt`
10. `fish --version` is `4.5.0`

## Comparison commands

Run these on another machine to compare against this one.

```bash
fish --version
cat ~/.config/omf/channel
cat ~/.config/omf/theme
cat ~/.config/omf/bundle
git -C ~/.local/share/omf rev-parse HEAD
fish -c 'functions fish_prompt | head -n 1'
fish -c 'functions fish_right_prompt | head -n 1'
fish -c 'set -S theme_short_path; echo SEP; set -S theme_stash_indicator; echo SEP; set -S theme_ignore_ssh_awareness'
sed -n '1,120p' ~/.config/fish/config.fish
```

To inspect the function source location more precisely:

```bash
fish -c 'functions fish_prompt | string collect'
fish -c 'functions fish_right_prompt | string collect'
```

## Additional factors that can change appearance

Even if the prompt string is the same, it can still look different on screen because of:

- terminal app
- font
- font fallback
- color theme
- whether the session is over SSH
- whether the current directory is a git repository

Terminal-related values on this machine:

- terminal: `ghostty`
- theme: `iTerm2 Light Background`
- font-family: `JetBrainsMono Nerd Font`
- fallback font-family: `Apple SD Gothic Neo`
- font-size: `14`

## Sync policy

This project should continue to sync:

- fish configuration that loads OMF
- OMF theme and bundle selection
- exact documentation of the OMF commit needed for reproduction

This project intentionally does not sync:

- the actual OMF theme function source

If the prompt differs, suspect the local OMF installation state before suspecting the repo-managed files.
