{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    enableOnBoot = false;
    enableNvidia = true;
  };

  users.users.mainUser.extraGroups = [ "docker" ];
}
