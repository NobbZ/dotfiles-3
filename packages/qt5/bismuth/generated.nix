# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
  bismuth = {
    pname = "bismuth";
    version = "7c49292f1d2f0980931b187747361a9ac6046008";
    src = fetchFromGitHub ({
      owner = "Bismuth-Forge";
      repo = "bismuth";
      rev = "7c49292f1d2f0980931b187747361a9ac6046008";
      fetchSubmodules = false;
      sha256 = "sha256-sYehZ9f+V7xeqYaw5p6BCm2XWsC/mpmsak6pUFIWAbI=";
    });
  };
}