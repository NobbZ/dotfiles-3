{
  packages,
  config,
  flakePath,
  ...
}: let
  pkg = packages.self.picom;
in {
  systemd.user.services = {
    picom = {
      Unit.Description = "X11 compositor";
      Service.ExecStart = "${pkg}/bin/picom --experimental-backends";
      Install.WantedBy = ["graphical-session.target"];
    };
  };

  home.packages = [pkg];

  xdg.configFile."picom/picom.conf".source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/modules/home-manager/picom/picom.conf";
}
