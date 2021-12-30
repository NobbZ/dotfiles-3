{ utils }:

let
  nixosModules = utils.lib.exportModules [
   ./nixos/common.nix
   ./nixos/desktop.nix
   ./nixos/docker.nix
   ./nixos/gaming.nix
   ./nixos/home-manager.nix
   ./nixos/host-gen6.nix
   ./nixos/host-qemu.nix
   ./nixos/kvm.nix
   ./nixos/printing.nix
   ./nixos/sops.nix
   ./nixos/mainUser-admin.nix
  ];
  homeModules = utils.lib.exportModules [
    ./home-manager/bat
    ./home-manager/fish
    ./home-manager/konsole
    ./home-manager/lsd
    ./home-manager/neofetch
    ./home-manager/neovim
    ./home-manager/starship
    ./home-manager/vscode
    ./home-manager/base.nix
    ./home-manager/fonts.nix
    ./home-manager/git.nix
    ./home-manager/gui.nix
    ./home-manager/flake-channels.nix
    ./home-manager/discord.nix
    ./home-manager/kde
    ./home-manager/syncthing.nix
  ];
in
{
  inherit nixosModules homeModules;
}
