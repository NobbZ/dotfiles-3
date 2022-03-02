let
  # From nixpkgs.lib
  mapAttrsToList = f: attrs:
    map (name: f name attrs.${name}) (builtins.attrNames attrs);

  genAttrs' = func: values: builtins.listToAttrs (map func values);

  removeSuffix = suffix: str: let
    sufLen = builtins.stringLength suffix;
    sLen = builtins.stringLength str;
  in
    if sufLen <= sLen && suffix == builtins.substring (sLen - sufLen) sufLen str
    then builtins.substring 0 (sLen - sufLen) str
    else str;

  exportModules = genAttrs' (
    arg: {
      name = removeSuffix ".nix" (baseNameOf arg);
      value = import arg;
    }
  );

  exportModulesDir = dir: (exportModules (mapAttrsToList (name: value: dir + "/${name}") (builtins.readDir dir)));

  folderToList = folder: (
    mapAttrsToList (key: value: folder + "/${key}") (
      builtins.readDir folder
    )
  );
in {
  inherit exportModules exportModulesDir folderToList;
}
