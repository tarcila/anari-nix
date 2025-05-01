{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  config,
  cudaSupport ? config.cudaSupport,
  optixSupport ? config.cudaSupport,
  cudaPackages,
  nvidia-optix,
  anari-sdk,
  libjpeg,
  libpng,
  libtiff,
  libGL,
  python3,
  openimageio,
  openvdb,
  osl,
  openexr,
  openjpeg,
  tbb_2021_11,
  pugixml,
  zlib,
}:
assert lib.assertMsg (!optixSupport || cudaSupport) "OptiX support requires CUDA support";
stdenv.mkDerivation {

  pname = "anari-cycles";
  version = "v0.0.0-20-g8b4ee2e";

  src = fetchFromGitHub {
    owner = "jeffamstutz";
    repo = "anari-cycles";
    rev = "8b4ee2e17bc3d0b66c9a5d46ac93bee34c8fc7d2";
    hash = "sha256-KcfvGGJqJWSIrR/kqZQS5gw/OcMaXYTLa7LaqJ3NaWg=";
    fetchSubmodules = true;
  };

  patches = [
    ./0001-Link-with-openvdb-when-needed.patch
    ./0002-Hardcode-Cycles-root-folder-to-CMAKE_INSTALL_PREFIX.patch
  ];

  nativeBuildInputs =
    [
      cmake
      python3
    ]
    ++ lib.optionals cudaSupport [
      cudaPackages.cuda_nvcc
    ];

  buildInputs =
    [
      anari-sdk
      libjpeg
      openimageio
      openjpeg
      osl
      pugixml
      libtiff
      openexr
      openvdb
      libpng
      zlib
      tbb_2021_11
    ]
    ++ lib.optionals (cudaSupport) [
      # CUDA and OptiX
      cudaPackages.cuda_cudart
      cudaPackages.cuda_cccl
      libGL
    ]
    ++ lib.optionals optixSupport [
      nvidia-optix
    ];

  cmakeFlags =
    [
      "-DWITH_CYCLES_DEVICE_HIP=OFF"
      "-DWITH_CYCLES_NANOVDB=ON"
      "-DWITH_CYCLES_OPENVDB=ON"
      "-DWITH_CYCLES_OSL=ON"
    ]
    ++ lib.optionals cudaSupport [
      "-DWITH_CYCLES_DEVICE_CUDA=ON"
      "-DWITH_CUDA_DYNLOAD=OFF"
      "-DWITH_CYCLES_CUDA_BINARIES=ON"
    ]
    ++ lib.optionals optixSupport [
      "-DWITH_CYCLES_DEVICE_OPTIX=ON"
      "-DCYCLES_RUNTIME_OPTIX_ROOT_DIR=${nvidia-optix}"
    ];

  postInstall = ''
    cmake --build cycles --target install
    rm -fr ''${out}/cycles
    rm -fr ''${out}/license
  '';

  meta = with lib; {
    description = "Blender Cycles, exposed through ANARI.";
    homepage = "https://github.com/jeffamstutz/anari-cycles";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
