{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  anari-sdk,
  pkg-config,
  cudaPackages,
  nvidia-optix,
  nvidia-mdl,
  python3,
}:
stdenv.mkDerivation {
  pname = "visrtx";
  version = "v0.11.0-75-ga711f42";

  # Main source.
  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "VisRTX";
    rev = "a711f4273717996cbbc0bbc4a70a38b40892c83e";
    hash = "sha256-6GWOmMAzohjww4ng2ZbXpFuI9mKX29eDT5LDHy5Rmos=";
  };

  cmakeFlags = [
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DOptiX_ROOT_DIR=${nvidia-optix}"
    "-DVISRTX_BUILD_GL_DEVICE=OFF"
    "-DVISRTX_ENABLE_MDL_SUPPORT=ON"
    "-DVISRTX_PRECOMPILE_SHADERS=OFF"
  ];

  patches = [
    ./disable-optix-headers-fetch.patch
  ];

  postFixup = ''
    patchelf --add-rpath ${nvidia-mdl}/lib/ $out/lib/libanari_library_visrtx.so
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
    cudaPackages.libcurand
    nvidia-optix

    # MDL
    nvidia-mdl
  ];

  meta = with lib; {
    description = "VisRTX is an experimental, scientific visualization-focused implementation of the Khronos ANARI standard.";
    homepage = "https://github.com/NVIDIA/VisRTX";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
