self: pkgs:
let
  inherit (pkgs) lib;
in
{
  nvidia-mdl = lib.warnOnInstantiate "nvidia-mdl has been renamed to mdl-sdk to better follow upstream name usage" pkgs.mdl-sdk;
}
