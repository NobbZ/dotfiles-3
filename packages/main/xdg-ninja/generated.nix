# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  xdg-ninja = {
    pname = "xdg-ninja";
    version = "33b6491dd4561f134a89a22db5513df27219a15e";
    src = fetchFromGitHub {
      owner = "b3nj5m1n";
      repo = "xdg-ninja";
      rev = "33b6491dd4561f134a89a22db5513df27219a15e";
      fetchSubmodules = false;
      sha256 = "sha256-9DTBEORVMlhGYpwmLUQNkksnW1eQUJW5crNLPJwn3M4=";
    };
    date = "2023-05-21";
  };
}
