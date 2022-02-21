#!/usr/bin/env bash


targets=($(nix flake show --json | jq -r '.packages."x86_64-linux" | to_entries[] | "\(.key)"'))
targets+=".#devShell.x86_64-linux.inputDerivation"
skip=(
    "base-vm"
    "g-papirus-icon-theme"
)


for i in "${targets[@]}"; do
    if [[ ! " ${skip[@]} " =~ " ${i} " ]]; then
        echo "Building $i"
        mkdir -p results/${i}
        pushd results/${i}
        nix build "../..#packages.x86_64-linux.${i}" -L
        popd
    else
        echo "Skipping $i"
    fi
done