# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:
{

  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "ahci" "nvme" "usbhid" ];
      kernelModules = [ ];
      supportedFilesystems = [ "zfs" ];
      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r zroot/gen6/nixos@empty
      '';
    };

    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod;
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "zfs" ];

    zfs = {
      enableUnstable = true;
      forceImportAll = false;
      forceImportRoot = false;
    };

    loader = {

      grub = {
        device = "nodev";
        enable = true;
        efiSupport = true;
        zfsSupport = true;
        gfxmodeEfi = "2560x1440";
        configurationLimit = 20;
        extraFiles = {
          "netboot.xyz.efi" = "${pkgs.netboot-xyz-images}/netboot.xyz.efi";
        };
        extraEntries = ''
          ### Start netboot.xyz
          menuentry "netboot.xyz" {
		        chainloader /netboot.xyz.efi
          }
          ### End netboot.xyz
        '';
      };

      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
    };
  };

  systemd = {
    services.systemd-remount-fs.wantedBy = lib.mkForce [ ];
    services.sanoid = {
      serviceConfig =  {
        DynamicUser = lib.mkForce false;
        Group = lib.mkForce "root";
        User = lib.mkForce "root";
      };
    };
  };

  networking = {
    hostName = "gen6";
    hostId = "01017f00";
    # useDHCP = true;
    # interfaces.eno1.useDHCP = true;
    networkmanager.enable = true;
  };

  programs = {
    steam.enable = true;
  };

  environment.systemPackages = with pkgs; [
    lutris
    libsForQt5.kdenlive
    ffmpeg
  ];

  services = {
    xserver = {
      layout = "us";
      videoDrivers = [ "nvidia" ];
      xkbOptions = "compose:rctrl";
    };

    sanoid = {
      enable = true;
      templates = {
        "normal" = {
          "frequently" = 0;
          "hourly" = 1;
          "daily" = 1;
          "monthly" = 4;
          "yearly" = 0;
          "autosnap" = true;
          "autoprune" = true;
        };
        "slow" = {
          "frequently" = 0;
          "hourly" = 0;
          "daily" = 0;
          "monthly" = 4;
          "yearly" = 0;
          "autosnap" = true;
          "autoprune" = true;
        };
      };
      settings = {
        "zroot/data/home" = {
          "use_template" = "normal";
        };
        "zroot/data/games" = {
          "use_template" = "slow";
        };
        "zroot/data/wine" = {
          "use_template" = "slow";
        };
        "zroot/data/steam" = {
          "use_template" = "slow";
        };
      };
    };

    zfs = {
      autoScrub = {
        enable = true;
        pools = [ "zroot" ];
        interval =  "weekly";
      };
    };
  };

  virtualisation.docker.storageDriver = "zfs";

  fileSystems."/" =
    {
      device = "zroot/gen6/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "zroot/nix";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/LINUXESP";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-label/LINUXSWAP"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    video.hidpi.enable = lib.mkDefault true;
    opengl.driSupport32Bit = true;
  };
}