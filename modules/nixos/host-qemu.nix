{ config, pkgs, ... }:
# https://github.com/serokell/deploy-rs/blob/715e92a13018bc1745fb680b5860af0c5641026a/examples/system/common.nix
{
  boot.loader.systemd-boot.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "btrfs";
  };

  users.users.mainUser = {
    name = "admin";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "1234";
  };

  services.openssh = { enable = true; };

  # security.sudo.extraRules = [{
  #   groups = [ "wheel" ];
  #   commands = [{
  #     command = "ALL";
  #     options = [ "NOPASSWD" ];
  #   }];
  # }];

}