# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  iosevka-normal = {
    pname = "iosevka-normal";
    version = "v1.3.0";
    src = fetchurl {
      url = "https://github.com/viperML/iosevka/releases/download/v1.3.0/iosevka.zip";
      sha256 = "sha256-HWKz73HvWc88Mfrtqkso4fCbdSj3bxKRH0Qk0oUWji8=";
    };
  };
}
