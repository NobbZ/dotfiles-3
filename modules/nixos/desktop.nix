{
  config,
  pkgs,
  lib,
  self,
  inputs,
  packages,
  ...
}: (lib.mkMerge [
  {
    time.timeZone = "Europe/Madrid";

    services = {
      pipewire = {
        enable = true;
        pulse.enable = true;
      };

      journald.extraConfig = ''
        Storage=volatile
      '';

      ananicy.enable = true;
      thermald.enable = true;
      udev.packages = [pkgs.android-udev-rules];
    };

    # replaced by pipewire
    hardware.pulseaudio.enable = false;

    environment.systemPackages = with pkgs; [
      # CLI to be found by default in other distros
      file
      xsel
      pciutils
      wget
      libarchive
      lsof
      usbutils
      # Icons
      # (packages.self.papirus-icon-theme.override {color = "adwaita";})
      (packages.self.colloid.override {
        theme = "yellow";
      })
    ];

    xdg.portal = {
      enable = true;
      gtkUsePortal = true;
    };

    nix.gc = {
      automatic = true;
      dates = "04:00";
      # options = "--delete-older-than 7d";
      options = "-d";
    };
  }
  (lib.mkIf config.services.xserver.displayManager.gdm.enable {
    # Fixes GDM autologin in Wayland
    # https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
  })
])
