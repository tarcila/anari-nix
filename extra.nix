{ lib }:
let
  # Supported systems
  defaultSystems = [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
  forAllSystems = lib.genAttrs defaultSystems;

  # Helper function that turns a attributeset {"packages" = { ...}  ... } returned by (f system)
  # into {"packages" = { <system> = { ... } }  ... }.
  forEachSystem =
    f: systems:
    let
      forOneSystem = f: system: builtins.mapAttrs (name: value: { "${system}" = value; }) (f system);
      merge = acc: set: builtins.mapAttrs (name: value: (acc.${name} or { }) // value) set;
    in
    builtins.foldl' merge { } (map (forOneSystem f) systems);

  # Same as above given the default set of default systems.
  forEachDefaultSystems = f: forEachSystem f defaultSystems;

in
{
  inherit
    defaultSystems
    forAllSystems
    forEachSystem
    forEachDefaultSystems
    ;

  # Create a `final` package set with overlays applied atop of `prev`
  applyOverlays =
    overlays: final: prev:
    lib.foldl' (lib.flip lib.extends) (_: prev) overlays final;
  # Create a `final` package set with overlays applied using, but not including, `prev`
  flattenOverlays =
    overlays: final: prev:
    lib.foldl' (acc: overlay: acc // (overlay final (prev // acc))) { } overlays;
}
