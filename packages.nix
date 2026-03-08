lib: _final: prev:
lib.packagesFromDirectoryRecursive {
  inherit (prev) callPackage newScope;
  directory = ./pkgs;
}
