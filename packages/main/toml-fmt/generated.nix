# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
  toml-fmt = {
    pname = "toml-fmt";
    version = "22ab50f4d64831cffd28777870526cc97e430474";
    src = fetchFromGitHub ({
      owner = "fenollp";
      repo = "toml-fmt";
      rev = "22ab50f4d64831cffd28777870526cc97e430474";
      fetchSubmodules = false;
      sha256 = "sha256-hkwgcjziB4Ax38A4v2HPfkMRIVlmYb4tfHOU/xLlXik=";
    });
  };
}