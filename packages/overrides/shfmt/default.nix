{
  shfmt,
  symlinkJoin,
  makeWrapper,
}:
symlinkJoin {
  inherit (shfmt) name meta;
  paths = [shfmt];
  buildInputs = [makeWrapper];
  postBuild = ''
    wrapProgram $out/bin/shfmt \
      --add-flags "-i 4"
  '';
}