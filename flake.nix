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
      # Expose our packages as an overlay
      overlays =
        let
          overlay = import ./default.nix;
        in
        {
          default = final: prev: overlay final prev;
        };

      templates = {
        simple = {
          description = "A basic template enabling supported anari devices and TSD to enable exploration";
          path = ./templates/simple;
        };
      };

      defaultTemplate = self.templates.simple;
    }
    // forEachDefaultSystems (
      system:
      let
        # Nixpkgs instantiated for supported system types.
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ (import ./overrides.nix) ];
        };

        # Same, enabling CUDA support
        pkgsCuda = lib.makeScope pkgs.newScope (self: {
          config.cudaSupport = true;
        });

        # Create our package set, based on a configurable nixpkgs source
        packagesFor =
          pkgs:
          let
            packages = builtins.removeAttrs (import ./packages.nix self.packages.${system} pkgs) [ "nixglenv" ];
          in
          lib.attrsets.filterAttrs (
            packageName: packageDesc:
            let
              packagePlatforms = packageDesc.meta.platforms or [ system ];
            in
            builtins.elem system packagePlatforms
          ) packages;

        # Instanciate our packages both for cuda and non-cuda pkgs.
        # CUDA is not exposed directly, but will be used for checks.
        packagesDefault = packagesFor pkgs;
        packagesCuda = packagesFor pkgsCuda;

        # CUDA quick introspection
        canDoCuda = system == "x86_64-linux" || system == "aarch64-linux";

        # Formatting configuration
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        # Expected flake outputs.
        packages = packagesDefault;
        formatter = treefmtEval.config.build.wrapper;
        checks = lib.attrsets.filterAttrs (name: value: lib.attrsets.isDerivation value) {
          packages = pkgs.linkFarm "packages" packagesDefault;
          packagesCuda = if canDoCuda then pkgs.linkFarm "packages-cuda" packagesCuda else null;
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
