{
  description = ''
    Some tools I am missing from the main nixpkgs store.
  '';

  nixConfig = {
    extra-substituters = [
      "https://dldt.cachix.org/"
    ];
    extra-trusted-public-keys = [
      "dldt.cachix.org-1:lF3I8Yijsqk+5+ZjH3QCLYrPvKadXpL41fsdIpM5Rss="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      extra = import ./extra.nix { inherit lib; };
      inherit (extra) flattenOverlays forEachDefaultSystems;
    in
    {
      # Expose our packages as an overlay
      overlays = {
        default = import ./default.nix;
      };

      templates = {
        simple = {
          description = "A basic template enabling supported anari devices and TSD to enable exploration";
          path = ./templates/simple;
        };

        default = self.templates.simple;
      };
    }
    // forEachDefaultSystems (
      system:
      let
        # Nixpkgs instantiated for supported system types.
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          # Make sure we first apply our local overrides
          overlays = [ (import ./overrides.nix) ];
        };

        # Same, enabling CUDA support
        pkgsCuda = lib.makeScope pkgs.newScope (self: {
          config.cudaSupport = true;
        });

        # Create our package set, based on a configurable nixpkgs source and a possible list
        # overlays
        packagesForWithOverlays =
          overlays: pkgs:
          let
            packages = builtins.removeAttrs (flattenOverlays overlays self.packages.${system} pkgs) [
              "nixglenv"
            ];
          in
          lib.attrsets.filterAttrs (
            packageName: packageDesc:
            let
              packagePlatforms = packageDesc.meta.platforms or [ system ];
            in
            builtins.elem system packagePlatforms
          ) packages;

        overlayPackages = import ./packages.nix;
        overlayAliases = import ./aliases.nix;

        packagesFor = pkgs: packagesForWithOverlays [ overlayPackages ] pkgs;
        packagesWithAliasesFor = pkgs: packagesForWithOverlays [ overlayPackages overlayAliases ] pkgs;

        # Instanciate our packages both for cuda and non-cuda pkgs.
        # CUDA is not exposed directly, but will be used for checks.
        packagesDefault = packagesWithAliasesFor pkgs;
        packagesCheckDefault = packagesFor pkgs;
        packagesCheckCuda = packagesFor pkgsCuda;

        # CUDA quick introspection
        canDoCuda = system == "x86_64-linux" || system == "aarch64-linux";

        # Formatting configuration
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        # Expected flake outputs.
        packages = packagesDefault;
        packagesCheck = packagesCheckDefault;
        formatter = treefmtEval.config.build.wrapper;
        checks = lib.attrsets.filterAttrs (name: value: lib.attrsets.isDerivation value) {
          packages = pkgs.linkFarm "packages" packagesCheckDefault;
          packagesCuda = if canDoCuda then pkgs.linkFarm "packages-cuda" packagesCheckCuda else null;
          format = treefmtEval.config.build.check self;
        };

        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              cachix
              nix-prefetch-git
              python3Packages.pygit2
              python3Packages.pygithub
            ];
          };
        };
      }
    );
}
