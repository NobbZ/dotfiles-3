{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.homeConfigurations = {
    "ayats" = withSystem "x86_64-linux" ({
      pkgs,
      system,
      ...
    }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit self inputs;
          packages = self.lib.mkPackages (inputs
            // {
              inherit self;
            })
          system;
        };
        modules = with self.homeModules; [
          ./home.nix
          common
          xdg-ninja
          inputs.nix-common.homeModules.channels-to-flakes
          inputs.home-manager-wsl.homeModules.default
          {wsl.baseDistro = "void";}
        ];
      });
  };

  flake.packages."x86_64-linux".zzz_home_ayats = self.homeConfigurations."ayats".config.home.activationPackage;
}
