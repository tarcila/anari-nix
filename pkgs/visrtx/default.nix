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
  version = "v0.11.0-20-gc0bf6ba";

  # Main source.
  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "VisRTX";
    rev = "c0bf6ba77a5479a802b17e8d78c6083f1de4bd83";
    hash = "sha256-TKnu0odEd1CENb79Q+ifyQI6ktu7+LFI2so/pzr7Chw=";
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
