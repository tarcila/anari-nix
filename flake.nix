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
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;

          overlays = [
            (import ./overrides.nix)
          ];
        };

        allPackages = import ./packages.nix self.packages.${system} pkgs;

        platformPackages = builtins.removeAttrs allPackages (
          builtins.filter (
            x: allPackages.${x} ? "meta" && !builtins.elem system allPackages.${x}.meta.platforms
          ) (builtins.attrNames allPackages)
        );
        packages = builtins.removeAttrs platformPackages [ "nixglenv" ];
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        allPackages = allPackages;
        packages = packages;
        formatter = treefmtEval.config.build.wrapper;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cachix
            nix-prefetch-git
            python3Packages.pygit2
            python3Packages.pygithub
          ];
        };

        checks = packages;
      }
    )
    // (
      # Expose the overlay to nixpkgs
      let
        overlay = import ./default.nix;
      in
      {
        overlays = {
          default = final: prev: overlay final prev;
        };

      }
    )
    // (
      # Expose package details for scripts to use
      with builtins;
      let

        allPackages =
          let
            uniquePackages =
              list: foldl' (acc: e: if elem e.name (catAttrs "name" acc) then acc else acc ++ [ e ]) [ ] list;
          in
          uniquePackages (concatMap attrValues (attrValues self.packages));

        # Source types
        isGithub =
          p:
          (p ? "src" && p.src ? "url")
          && (match "(https://|ssh\+git://|git@)github.com/.*" p.src.url) != null;

        isPath = p: (p ? "src" && typeOf p.src == path);

        # Build default package details
        packageDetail = p: {
          definition = builtins.head (builtins.split '':[0-9]+'' p.meta.position);
          version = p.version;
        };

        # Path source package details
        pathPackageDetail =
          p:
          if (isPath p) then
            {
              sourcetype = "path";
              path = p.src;
            }
          else
            { };

        # Build github package details
        githubPackageDetail =
          p:
          if (isGithub p) then
            {
              sourcetype = "github";
              owner = p.src.owner;
              repo = p.src.repo;
              rev = p.src.rev;
              hash = p.src.outputHash;
              url = p.src.url;
            }
            // (if p.src ? "tag" && p.src.tag != null then { tag = p.src.tag; } else { })
            // (if p.src ? "branchName" && p.src.branchName != null then { ref = p.src.branchName; } else { })
          else
            { };
      in
      {
        # All packages
        packagesDetails =
          let
            createDetail = p: packageDetail p // githubPackageDetail p // pathPackageDetail p;
          in
          listToAttrs (
            map (p: {
              name = p.pname;
              value = createDetail p;
            }) allPackages
          );
      }
    );
}
