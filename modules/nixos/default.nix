{config, ...}: {
  flake.nixosModules = config.flake.lib.importFilesToAttrs ./. [
    "common"
    "containerd"
    "docker"
    "gnome"
    "hyprland"
    "plasma5"
    "podman"
    "sway"
    "tailscale"
    "user-ayats"
    "user-soch"
    "warp"
    "wine"
  ];
}
