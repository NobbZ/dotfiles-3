{
  withSystem,
  self,
  inputs,
  _inputs,
  ...
}: {
  flake.nixosConfigurations."gen6" = withSystem "x86_64-linux" (
    {
      pkgs,
      system,
      ...
    }:
      self.lib.mkSystem {
        inherit system pkgs;
        specialArgs = {
          inherit self;
          inputs = _inputs;
          packages = self.lib.mkPackages _inputs system;
          flakePath = "/home/ayats/Documents/dotfiles";
        };
        nixosModules = with self.nixosModules; [
          ./configuration.nix
          desktop
          xdg-ninja

          virt
          docker
          # podman
          printing
          ld
          inputs.vscode-server.nixosModules.default
          {
            services.vscode-server = {
              enable = true;
              installPath = "~/.local/share/code-server/.vscode-server";
            };
          }
          flatpak
          inputs.envfs.nixosModules.envfs

          ./fix-bluetooth.nix

          hardware-amd
        ];
        homeModules = with self.homeModules; [
          ./home.nix
          common
          xdg-ninja
          gui
          # nh # FIXME
          flatpak
        ];
        specialisations = [
          # (self.lib.joinSpecialisations (with self.specialisations; [
          #   gnome
          #   ayats
          # ]))
          (self.lib.joinSpecialisations (with self.specialisations; [
            gnome
            wayland
            ayats
          ]))
          # (self.lib.joinSpecialisations (with self.specialisations; [
          #   kde
          #   wayland
          #   ayats
          #   default
          # ]))
          (self.lib.joinSpecialisations (with self.specialisations; [
            sway
            wayland
            ayats
            default
          ]))
          # (self.lib.joinSpecialisations (with self.specialisations; [
          #   hyprland
          #   wayland
          #   ayats
          # ]))
        ];
      }
  );
}
