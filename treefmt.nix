{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";
  programs.black.enable = true;
  programs.cmake-format.enable = true;
  programs.jsonfmt = {
    enable = true;
    package = pkgs.hujsonfmt;
  };
  programs.just.enable = true;
  programs.mdformat.enable = true;
  programs.nixfmt.enable = true;
  programs.shfmt.enable = true;
  programs.yamlfmt.enable = true;
}
