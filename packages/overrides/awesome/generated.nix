# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
  awesome = {
    pname = "awesome";
    version = "4a140ea5ea681e7a0f62d8ef050b0ed1b905cc68";
    src = fetchFromGitHub ({
      owner = "awesomeWM";
      repo = "awesome";
      rev = "4a140ea5ea681e7a0f62d8ef050b0ed1b905cc68";
      fetchSubmodules = false;
      sha256 = "sha256-OAd8yEcVsIhwwgy8k2mDP2YhB4YIfQgahn2T9mjkLkM=";
    });
    date = "2022-09-22";
  };
}
