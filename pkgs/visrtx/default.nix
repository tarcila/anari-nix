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
  version = "v0.11.0-9-gc284c38";

  # Main source.
  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "VisRTX";
    rev = "c284c380dc63c7b2a93e617327c96cf9d69f4ab5";
    hash = "sha256-niNFKG6QxzXvEhklsDh7aPaPK9TLgOccir+kVvYwkg8=";
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
