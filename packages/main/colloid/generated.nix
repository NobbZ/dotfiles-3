# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  colloid = {
    pname = "colloid";
    version = "2023.04.11";
    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Colloid-gtk-theme";
      rev = "2023.04.11";
      fetchSubmodules = false;
      sha256 = "sha256-lVHDQmu9GLesasmI2GQ0hx4f2NtgaM4IlJk/hXe2XzY=";
    };
  };
}
