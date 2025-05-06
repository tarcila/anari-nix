{
  description = ''
    An simple anari-nix template
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
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    anari-nix.url = "github:dldt/anari-nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      anari-nix,
      treefmt-nix,
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
    forEachDefaultSystems (
      system:
      let
        # Let's bring in nixpkgs
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = system == "x86_64-linux" || system == "aarch64-linux";
          };
          overlays = [ anari-nix.overlays.default ];
        };

        # ANARI specific
        anariDevicePackages =
          with pkgs;
          (
            [
              anari-cycles
              anari-visionaray
              anari-ospray
            ]
            ++ (lib.optionals pkgs.config.cudaSupport [
              anari-barney
              visrtx
            ])
            ++ (lib.optionals (system == "x86_64-linux") [ visgl ])
          );

        anariDevices =
          pkgs:
          pkgs.symlinkJoin {
            name = "anari-devices";
            paths = anariDevicePackages;
          };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      in
      {
        packages = {
          somePackage = pkgs.stdenv.mkDerivation {
            pname = "some-package";
            version = "1.0.0";
            dontUnpack = true;
            installPhase = ''
              mkdir -p $out/bin
              echo -e "#!/bin/sh\necho Hello, world!" > $out/bin/hello
              chmod +x $out/bin/hello
            '';
            meta = with lib; {
              description = "A simple package";
              license = licenses.mit;
              mainProgram = "hello";
            };
          };
        };
        defaultPackage = self.packages.${system}.somePackage;

        # The devShell for each system type.
        devShells = {
          default = pkgs.mkShellNoCC {
            packages = (anariDevices pkgs) // {
              inherit (pkgs) tsd;
            };
          };
        };

        # Treefmt
        formatter = treefmtEval.config.build.wrapper;
      }
    );
}
