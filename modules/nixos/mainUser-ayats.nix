{ config, pkgs, ... }:

{
  users.mutableUsers = true; # change passwords of users

  users.users.mainUser = {
    name = "ayats";
    home = "/home/ayats";
    description = "Fernando Ayats";
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "uucp" "systemd-journal" "networkmanager" ];
    # passwordFile = config.sops.secrets."initialPassword/ayats".path;
    initialPassword = "1234";
  };
}
