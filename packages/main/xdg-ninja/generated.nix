# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
  xdg-ninja = {
    pname = "xdg-ninja";
    version = "3e1e983bf4184c5610d723681ee929d833736a43";
    src = fetchFromGitHub ({
      owner = "b3nj5m1n";
      repo = "xdg-ninja";
      rev = "3e1e983bf4184c5610d723681ee929d833736a43";
      fetchSubmodules = false;
      sha256 = "sha256-ypcoHLyz++3aLXlAElXu0r0//eo1VJM6Npfb3ItI89A=";
    });
  };
}