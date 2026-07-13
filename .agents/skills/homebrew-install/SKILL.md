---
name: homebrew-install
description: Install software with Homebrew while keeping a repository-managed Brewfile synchronized. Use whenever the user asks to install, add, or set up a Homebrew formula, cask, or third-party tap, including requests that provide a package URL or say to use brew/Homebrew. If the current repository contains a Brewfile, updating it is part of completion, not an optional follow-up.
---

# Homebrew Install

Install the requested package and preserve the same setup declaratively in the
current repository when it manages Homebrew with a `Brewfile`.

## Workflow

1. Inspect the current state before installing.
   - Run `git status --short` and preserve unrelated user changes.
   - Find repository-managed manifests with `rg --files -g 'Brewfile'`.
   - Prefer the repository-root `Brewfile`; ask only if multiple candidates make
     ownership genuinely ambiguous.

2. Resolve the official Homebrew identity.
   - Verify current official installation instructions when given a URL or a
     third-party package.
   - Determine the exact tap and whether the package is a formula or cask.
   - Inspect a third-party formula/cask definition before trusting it.
   - When tap trust is required, prefer artifact-scoped trust such as
     `brew trust --formula owner/tap/name` or
     `brew trust --cask owner/tap/name`. Do not trust an entire tap unless the
     artifact-scoped form is insufficient or the user explicitly requests it.

3. Synchronize the `Brewfile`.
   - When a repository `Brewfile` exists, add the required `tap` and exactly one
     matching `brew` or `cask` entry.
   - Preserve its grouping, comments, quoting, and alphabetical ordering.
   - Avoid duplicates and do not rewrite unrelated entries.
   - Do not use `brew bundle dump --force`; it can add unrelated software from
     the local machine.
   - If no `Brewfile` exists, continue the installation and state that no
     manifest was available to update.

4. Install the package.
   - Add the official tap when required.
   - Run `brew install <formula>` or `brew install --cask <cask>` as appropriate.
   - If it is already installed, keep it in place and still ensure the
     `Brewfile` records it. Do not upgrade unless requested.

5. Verify both sides of the result.
   - Confirm the installed version with `brew list --versions <formula>` or
     `brew list --cask --versions <cask>`.
   - Confirm the expected tap and package entries are present in the `Brewfile`.
   - Run `git diff --check` and inspect the focused `Brewfile` diff.
   - Use `brew bundle check --file <Brewfile>` when useful, but distinguish
     unrelated unmet dependencies from failures caused by the new entry.

6. Report the installed version, manifest changes, and verification result.
   Do not commit or push unless the user separately requests it.

## Completion Rule

Do not report a Homebrew installation complete while a repository-managed
`Brewfile` exists but does not contain the installed package and required tap.
