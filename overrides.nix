self: pkgs:
{
  embree = pkgs.embree.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      "-DEMBREE_ISPC_SUPPORT=ON"
    ];
  });
}
# Handle CUDA CMake implicit directory fix.
// (
  let
    overrideWithSetupHook =
      cudaPackages:
      cudaPackages.overrideScope (
        self: super:
        let
          inherit (super.backendStdenv) cc;
          update-what = if super ? "cuda_nvcc" then "cuda_nvcc" else "cudatoolkit";
          setupHook = pkgs.makeSetupHook {
            name = "cmake-filter-implicit-paths-hook";
            substitutions = {
              # Will be used to compute exclusion path.
              ccFullPath = "${cc}/bin/${cc.targetPrefix}c++";
            };
          } ./hooks/cuda-filter-cmake-implicit-paths-hook.sh;
        in
        {
          ${update-what} = super.${update-what}.overrideAttrs (old: {
            propagatedBuildInputs =
              (if old ? "propagatedBuildInputs" then old.propagatedBuildInputs else [ ])
              ++ [ setupHook ];
          });
        }
      );

    allCudaPackagesNames = builtins.filter (x: pkgs.lib.strings.hasPrefix "cudaPackages" x) (
      builtins.attrNames pkgs
    );
  in
  builtins.foldl' (
    acc: elem:
    {
      ${elem} = overrideWithSetupHook pkgs.${elem};
    }
    // acc
  ) { } allCudaPackagesNames
)
