{
  config,
  pkgs,
  self,
  lib,
  ...
}: {
  nh = {
    enable = true;
    clean.enable = true;
  };

  nix = {
    daemonCPUSchedPolicy = "idle";
    settings = import ../../misc/nix-conf.nix // import ../../misc/nix-conf-privileged.nix;
  };

  services.udev.packages = with pkgs; [
    android-udev-rules
  ];

  environment.defaultPackages = [];
  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    vim

    config.packages.self.git

    android-tools
  ];

  # environment.defaultPackages = [
  #   pkgs.xsel
  #   pkgs.pciutils
  #   pkgs.usbutils
  #   pkgs.step-cli
  #   packages.self.git
  # ];

  i18n = let
    defaultLocale = "en_US.UTF-8";
    es = "es_ES.UTF-8";
  in {
    inherit defaultLocale;
    extraLocaleSettings = {
      LANG = defaultLocale;
      LC_COLLATE = defaultLocale;
      LC_CTYPE = defaultLocale;
      LC_MESSAGES = defaultLocale;

      LC_ADDRESS = es;
      LC_IDENTIFICATION = es;
      LC_MEASUREMENT = es;
      LC_MONETARY = es;
      LC_NAME = es;
      LC_NUMERIC = es;
      LC_PAPER = es;
      LC_TELEPHONE = es;
      LC_TIME = es;
    };
  };

  systemd = let
    extraConfig = ''
      DefaultTimeoutStopSec=15s
    '';
  in {
    inherit extraConfig;
    user = {inherit extraConfig;};
    services."getty@tty1".enable = false;
    services."autovt@tty1".enable = false;
    services."getty@tty7".enable = false;
    services."autovt@tty7".enable = false;

    # TODO channels-to-flakes
    tmpfiles.rules = [
      "D /nix/var/nix/profiles/per-user/root 755 root root - -"
    ];
  };

  home-manager = {
    # useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      {
        home.stateVersion = lib.mkForce config.system.stateVersion;
      }
    ];
  };

  programs.ssh = {
    startAgent = true;
    agentTimeout = "8h";
  };

  fonts.fonts = [
    pkgs.roboto
    config.packages.self.iosevka
  ];

  # TODO is this working?
  nixpkgs.overlays = [
    (_final: prev: {
      arcanPackages = prev.arcanPackages.overrideScope' (_arcan_final: arcan_prev: {
        espeak = arcan_prev.espeak.override {
          mbrolaSupport = false;
          pcaudiolibSupport = false;
          sonicSupport = false;
        };
      });
    })
  ];
}