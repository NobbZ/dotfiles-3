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
          flatpak

          ./nspawn.nix

          ./fix-bluetooth.nix
          inputs.nix-gaming.nixosModules.pipewireLowLatency
          {
            services.pipewire.lowLatency.enable = true;
          }

          hardware-nvidia
        ];
        homeModules = with self.homeModules; [
          ./home.nix
          common
          xdg-ninja
          gui
          nh
          flatpak
        ];
        specialisations = [
          (self.lib.joinSpecialisations (with self.specialisations; [
            kde
            ayats
            default
          ]))
          (self.lib.joinSpecialisations (with self.specialisations; [
            hyprland
            ayats
          ]))
          # (self.lib.joinSpecialisations (with self.specialisations; [
          #   {
          #     name = "cinnamon";
          #     nixosModules = [
          #       (args: {
          #         services.xserver = {
          #           enable = true;
          #           desktopManager.cinnamon = {
          #             enable = true;
          #           };
          #           displayManager.lightdm = {
          #             enable = true;
          #           };
          #         };
          #       })
          #     ];
          #   }
          #   ayats
          #   default
          # ]))
        ];
      }
  );
}
