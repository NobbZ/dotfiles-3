#!/usr/bin/env bash
PNAME=colloid
nix-update -f $(git-root) $PNAME
if [[ `git status --porcelain --untracked-files=no` ]]; then
    nix build .#$PNAME
fi
