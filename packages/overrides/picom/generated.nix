# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  picom = {
    pname = "picom";
    version = "05ef18d78f96a0a970742f1dff40fcf505a0daa6";
    src = fetchFromGitHub ({
      owner = "yshui";
      repo = "picom";
      rev = "05ef18d78f96a0a970742f1dff40fcf505a0daa6";
      fetchSubmodules = false;
      sha256 = "sha256-AvtN1aE9zCsaf2UR4vzPExnJTibYACGDuQcTpOEUkpM=";
    });
    date = "2023-04-01";
  };
}
