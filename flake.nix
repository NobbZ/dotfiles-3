{
  description = "Fernando Ayats's system configuraion";

  inputs = {
    inherit (nixpkgs) lib;
    inherit (lib) attrValues;


    inherit (util) host;
    inherit (util) user;
    inherit (util) shell;
    inherit (util) app;

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
  };

  # We take nixpkgs and home-manager as input
  outputs = inputs @ { self, nixpkgs, home-manager, nur }:
    let

      pkgs = import nixpkgs {
        inherit system;
        config = { allowBroken = true; allowUnfree = true; };
        overlays = [
          nur.overlay
        ];
      };

      system = "x86_64-linux";

    in {
      homeManagerConfigurations = {
        ayats = home-manager.lib.homeManagerConfiguration {
          configuration = { pkgs, lib, ... }: {
            imports = [
              # Split configs per package
              ./home-manager/home.nix
              ./neovim/nvim.nix
              ./fish/fish.nix
              ./bat/bat.nix
              ./lsd/lsd.nix
              ./neofetch/neofetch.nix
            ];
            nixpkgs = {
              config = { allowUnfree = true; };
            };
          };
          system = "x86_64-linux";
          homeDirectory = "/home/ayats";
          username = "ayats";
        };
      };

    };
}
