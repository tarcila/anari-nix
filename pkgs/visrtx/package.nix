{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  anari-sdk,
  pkg-config,
  cudaPackages,
  materialx,
  mdl-sdk,
  nvidia-optix,
  python3,
  nix-update-script,
}:
stdenv.mkDerivation {
  pname = "visrtx";
  version = "tsd_removed-unstable-2026-10-14";

  # Main source.
  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "VisRTX";
    rev = "3876abfb68d930f54834a2f13694ffef24b384be";
    hash = "sha256-WfNnQlbw3HoF1Z6Zq79cxp4VBlPt+8VWHUAJTKVQYi8=";
  };

  cmakeFlags = with lib; [
    (cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)
    (cmakeFeature "OptiX_ROOT_DIR" (toString nvidia-optix))
    (cmakeBool "VISRTX_BUILD_GL_DEVICE" false)
    (cmakeBool "VISRTX_ENABLE_MDL_SUPPORT" true)
    (cmakeBool "VISRTX_ENABLE_MATERIALX_SUPPORT" true)
    (cmakeBool "VISRTX_PRECOMPILE_SHADERS" false)

    (cmakeFeature "OPTIX_FETCH_VERSION" "${versions.majorMinor nvidia-optix.version}")
    (cmakeBool "VISRTX_ENABLE_NEURAL" false)
  ];

  patches = [
    ./disable-optix-headers-fetch.patch
  ];

  postFixup = ''
    patchelf --add-rpath ${mdl-sdk}/lib/ $out/lib/libanari_library_visrtx.so
  '';

  nativeBuildInputs = [
    cudaPackages.cuda_nvcc

    cmake
    pkg-config
    python3
  ];

  buildInputs = [
    anari-sdk

    # CUDA and OptiX
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cccl
    (lib.getDev cudaPackages.cuda_nvml_dev)

    cudaPackages.libcurand
    cudaPackages.libcurand.static
    nvidia-optix

    # MDL, MaterialX
    materialx
    mdl-sdk
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--flake"
    ];
  };

  meta = with lib; {
    description = "VisRTX is an experimental, scientific visualization-focused implementation of the Khronos ANARI standard.";
    homepage = "https://github.com/NVIDIA/VisRTX";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
