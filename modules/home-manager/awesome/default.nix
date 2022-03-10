args @ {
  config,
  lib,
  self,
  pkgs,
  ...
}: let
  inherit (builtins) mapAttrs attrValues;
  inherit (pkgs) fetchFromGitHub;

  selfPath =
    if lib.hasAttr "FLAKE" config.home.sessionVariables
    then "${config.home.sessionVariables.FLAKE}/modules/home-manager/awesome"
    else "${self.outPath}/modules/home-manager/awesome";
  finalPath = "${config.home.homeDirectory}/.config/awesome";

  modules = import ./modules.nix {inherit pkgs;};

  mkService = serviceAttrs:
    lib.recursiveUpdate {
      Unit.PartOf = ["graphical-session.target"];
      Unit.After = ["graphical-session.target"];
      Install.WantedBy = ["awesome-session.target"];
    }
    serviceAttrs;

  xsettingsConfig = import ./xsettings.nix {inherit args;};

  xsettingsd-switch-script = pkgs.writeShellScript "xsettings-switch" ''
    export PATH="${pkgs.coreutils-full}/bin:${pkgs.systemd}/bin"
    if (( $(date +"%-H%M") < 1800 )) && (( $(date +"%-H%M") > 0500 )); then
      ln -sf ${xsettingsConfig.light} ${config.xdg.configHome}/xsettingsd/xsettingsd.conf
    else
      ln -sf ${xsettingsConfig.dark} ${config.xdg.configHome}/xsettingsd/xsettingsd.conf
    fi
    systemctl --user restart xsettingsd.service
  '';
in {
  home.packages = with pkgs; [
    nitrogen
    lxrandr
    adw-gtk3
  ];

  systemd.user.tmpfiles.rules =
    map (f: "L+ ${finalPath}/${f} - - - - ${selfPath}/${f}") [
      "rc.lua"
      "helpers.lua"
      "theme.lua"
      "res"
    ]
    ++ attrValues (mapAttrs (name: value: "L+ ${finalPath}/${name} - - - - ${value.outPath}") modules);

  systemd.user.targets.awesome-session = {
    Unit = {
      Description = "awesome window manager session";
      BindsTo = ["graphical-session.target"];
      Wants = ["graphical-session-pre.target"];
      After = ["graphical-session-pre.target"];
    };
  };

  systemd.user.services = {
    nitrogen = mkService {
      Unit.Description = "Wallpaper chooser";
      Service.ExecStart = "${pkgs.nitrogen}/bin/nitrogen --restore";
    };
    nm-applet = mkService {
      Unit.Description = "Network manager applet";
      Service.ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
    };
    autorandr-boot = mkService {
      Unit.Description = "Load autorandr on boot";
      Service.ExecStart = "${pkgs.autorandr}/bin/autorandr --change";
    };
    polkit-agent = mkService {
      Unit.Description = "GNOME polkit agent";
      Service.ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    };
    xsettingsd = mkService {
      Unit.Description = "Cross desktop configuration daemon";
      Service.ExecStart = "${pkgs.xsettingsd}/bin/xsettingsd";
      Unit.After = ["xsettingsd-switch.service"];
    };
    xsettingsd-switch = mkService {
      Unit.Description = "Reload the xsettingsd with new configuration";
      Service.ExecStart = xsettingsd-switch-script.outPath;
    };
  };

  systemd.user.timers = {
    xsettingsd-switch = {
      Unit.Description = "Apply xsettings on schedule";
      Unit.PartOf = ["xsettingsd-switch.service"];
      Timer.OnCalendar = ["*-*-* 18:01:00" "*-*-* 05:01:00"];
      Install.WantedBy = ["timers.target"];
    };
  };

  programs.autorandr = {
    enable = true;
    profiles = {
      "gen6" = {
        fingerprint."DP-2" = "00ffffffffffff003669a73f86030000091d0104a53c22783b1ad5ae5048a625125054bfcf00d1c0714f81c0814081809500b3000101695e00a0a0a029503020b80455502100001af8e300a0a0a032500820980455502100001e000000fd003090dede3c010a202020202020000000fc004d5349204d41473237314351520169020320714d0102031112130f1d1e0e901f04230917078301000065030c0010006fc200a0a0a055503020350055502100001a5a8700a0a0a03b503020350055502100001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b8";
        config."DP-2" = {
          crtc = 0;
          mode = "2560x1440";
          position = "0x0";
          rate = "144.00";
        };
      };
    };
  };
}