{
  description = "Personal infrastructure flake";

  outputs = inputs @ { self, nixpkgs, flake-utils-plus, ... }:
    let
      modules = import ./modules { inherit flake-utils-plus; };
    in
    flake-utils-plus.lib.mkFlake {

      inherit self inputs;
      supportedSystems = [ "x86_64-linux" ];

      # Export modules
      inherit (modules) nixosModules homeModules;

      # Export lib
      lib =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          lib = nixpkgs.lib;
        in
        import ./lib { inherit pkgs lib; };

      # Channels configurations
      channelsConfig.allowUnfree = true;
      overlay = import ./overlay;
      sharedOverlays = [
        self.overlay
        inputs.nur.overlay
        inputs.powercord-overlay.overlay
      ];

      # Hosts definitions
      hostDefaults.modules = with modules.nixosModules; [
        common
      ];

      hosts = {
        gen6.modules = with modules.nixosModules; [
          host-gen6
          desktop
          mainUser-ayats
          inputs.home-manager.nixosModules.home-manager
          home-manager
          inputs.sops-nix.nixosModules.sops
          sops

          kvm
          docker
          printing
          gaming
        ] ++ [
          # Split into 2, so the previous `with modules.nixosModules` namespace
          # doesn't get inserted here
          {
            home-manager.sharedModules = with modules.homeModules; [
              base
              flake-channels
              fonts
              gui
              git

              bat
              fish
              konsole
              lsd
              neofetch
              neovim
              vscode
              discord
              kde
              syncthing
            ];
          }
        ];

        nix3.modules = with modules.nixosModules; [
          host-nix3
          desktop
          mainUser-ayats
          inputs.home-manager.nixosModules.home-manager
          home-manager

          docker
          printing
        ] ++ [
          # Split into 2, so the previous `with modules.nixosModules` namespace
          # doesn't get inserted here
          {
            home-manager.sharedModules = with modules.homeModules; [
              base
              flake-channels
              fonts
              gui
              git

              bat
              fish
              konsole
              lsd
              neofetch
              neovim
              vscode
              discord
              kde
            ];
          }
        ];

        test_server.modules = with modules.nixosModules; [
          inputs.nixos-generators.nixosModules.qcow

          mainUser-admin
          # inputs.modded-minecraft-servers.module
          minecraft-server
        ];
      };

      deploy.nodes.local-vm = {
        # sshOpts = [ "-p" "22" ];
        hostname = "192.168.122.98";
        fastConnection = true;
        profiles = {
          system = {
            sshUser = "admin";
            path =
              inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.test_server;
            user = "root";
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;


      outputsBuilder = channels: with channels.nixpkgs; {
        devShell = mkShell {
          name = "dotfiles";
          buildInputs = [
            git
            gnumake
            jq
            nixos-install-tools
            nixUnstable
            ripgrep
            update-nix-fetchgit
            inputs.deploy-rs.defaultPackage.${system}
          ];
          shellHook = ''
            export NIX_USER_CONF_FILES="$(pwd)/modules/nix.conf"
            export FLAKE="/home/ayats/.dotfiles"
            echo -e "\n\e[34m❄ Welcome to viperML/dotfiles ❄"
            echo "Last flake update:"
            git log -1 --pretty="format:%ch" flake.lock
            echo -e "\n\e[34m❄ Changes to the running NixOS config: ❄"
            echo -e "\e[0m"
            git --no-pager diff $(nixos-version --json | jq -r '.configurationRevision') -p
          '';
        };

        packages = {
          inherit
            lightly
            sierrabreezeenhanced
            multiload-ng
            any-nix-shell
            papirus-icon-theme
            netboot-xyz-images
            ;
        } // {

          base-vm = inputs.nixos-generators.nixosGenerate {
            pkgs = channels.nixpkgs;
            format = "qcow";
            modules = with modules.nixosModules; [
              mainUser-admin
            ];
          };

        };
      };

      templates = {
        poetry-flake = {
          path = ./templates/poetry-flake;
          description = "Flake for reproducible environments with poetry";
        };
        latex-flake = {
          path = ./templates/latex-flake;
          description = "Flake for reproducible latex documents";
        };
        base-flake = {
          path = ./templates/base-flake;
          description = "Basic flake with flake-utils-plus";
        };
      };

      defaultTemplate = self.templates.base-flake;

      # homeConfigurations = {
      #   "ayats" = inputs.home-manager.lib.homeManagerConfiguration rec {
      #     system = "x86_64-linux";
      #     username = "ayats";
      #     homeDirectory = "/home/${username}";
      #     pkgs = self.pkgs.${system}.nixpkgs;
      #     configuration = {
      #       # see modules/base-home.nix for information about this
      #       home = {
      #         file = lib.mapAttrs' (name: value: { name = ".nix-inputs/${name}"; value = { source = value.outPath; }; }) inputs;
      #       };
      #     };
      #     extraModules = [
      #       base-home
      #       bat
      #       fish
      #       git
      #       home-fonts
      #       home-gui
      #       konsole
      #       lsd
      #       neofetch
      #       neovim
      #       vscode
      #     ];
      #   };
      # };


      # nix-on-droid = inputs.nix-on-droid.lib.aarch64-linux.nix-on-droid {
      #   config = {};
      #   extraModules = with mods.nixosModules; [
      #     nix-on-droid
      #   ];
      # };
    };

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

    flake-utils-plus.url = github:gytis-ivaskevicius/flake-utils-plus/v1.3.1;

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = github:t184256/nix-on-droid;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    nur.url = github:nix-community/NUR;

    powercord-overlay.url = "github:LavaDesu/powercord-overlay";

    sops-nix = {
      url = github:Mic92/sops-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = github:serokell/deploy-rs;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = github:nix-community/nixos-generators;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    modded-minecraft-servers = {
      url = github:mkaito/nixos-modded-minecraft-servers;
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
}
