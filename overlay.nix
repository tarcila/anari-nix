nixpkgs:
let
  inherit (nixpkgs) lib;
in
lib.composeManyExtensions [
  (import ./overrides.nix)
  (import ./packages.nix lib)
  (import ./python-packages.nix lib)
  (import ./aliases.nix lib)
]
