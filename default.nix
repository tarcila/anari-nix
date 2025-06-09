final: prev:
let
  inherit (prev) lib;
  extra = import ./extra.nix { inherit lib; };

  overrides = import ./overrides.nix;
  packages = import ./packages.nix;
  aliases = import ./aliases.nix;
in
extra.applyOverlays [ overrides packages aliases ] final prev
