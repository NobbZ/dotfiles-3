{
  config,
  pkgs,
  lib,
  packages,
  ...
}: let
  my-extensions = with pkgs.gnomeExtensions; [
    appindicator
    blur-my-shell
    dash-to-panel
    sound-output-device-chooser
    system-monitor
    syncthing-indicator
    caffeine
    just-perfection
    #
    pop-shell
    forge
    gtile
    paperwm
  ];

  fix_extension = pkgs.writers.writePython3 "fix_extension" {} (builtins.readFile ./fix_extension.py);
  gnome-version = builtins.head (lib.splitString "." pkgs.gnome.gnome-shell.version);
  my-patched-extensions =
    builtins.map (ext: (ext.overrideAttrs (prev: {
      postInstall =
        prev.postInstall
        or ""
        + ''
          ${fix_extension} $out/share/gnome-shell/extensions/*/metadata.json ${gnome-version}
        '';
    })))
    my-extensions;
in {
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    displayManager.defaultSession = "gnome-xorg";
    displayManager.autoLogin.enable = true;
  };

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-photos
    gnome-tour

    gnome.gnome-characters
    gnome.cheese
    gnome.gnome-terminal
    gnome.gedit
    gnome.totem
    gnome.geary
    gnome.gnome-screenshot
    gnome.eog
  ];

  environment.systemPackages = with pkgs;
    [
      packages.self.adw-gtk3
      gnome.gnome-tweaks
      gnome.gnome-shell-extensions
      gnome.dconf-editor
      plasma5Packages.gwenview
    ]
    ++ my-patched-extensions;

  programs.xwayland.enable = true;
}
