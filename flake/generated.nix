# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  nix = {
    pname = "nix";
    version = "2.16.0";
    src = fetchgit {
      url = "https://github.com/nixos/nix.git";
      rev = "2.16.0";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-KjcQkI2HgbP7KOlHxb2DvyHISQXo2OExvvjqTyK7P0o=";
    };
  };
}
