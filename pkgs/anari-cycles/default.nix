{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  config,
  cudaSupport ? config.cudaSupport,
  cudaPackages_12_6,
  anari-sdk,
  libjpeg,
  libpng,
  libtiff,
  python3,
  openimageio,
  openvdb,
  openexr,
  openjpeg,
  tbb_2022_0,
  pugixml,
  zlib,
}:
stdenv.mkDerivation {
  pname = "anari-cycles";
  version = "v0.0.0-20-g8b4ee2e";

  # Main source.
  src = fetchFromGitHub {
    owner = "jeffamstutz";
    repo = "anari-cycles";
    rev = "8b4ee2e17bc3d0b66c9a5d46ac93bee34c8fc7d2";
    hash = "sha256-KcfvGGJqJWSIrR/kqZQS5gw/OcMaXYTLa7LaqJ3NaWg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs =
    [
      cmake
      python3
    ]
    ++ lib.optionals cudaSupport [
      cudaPackages_12_6.cuda_nvcc
    ];

  buildInputs =
    [
      anari-sdk
      libjpeg
      openimageio
      openjpeg
      pugixml
      libtiff
      openexr
      openvdb
      libpng
      zlib
      tbb_2022_0
    ]
    ++ lib.optionals cudaSupport [
      # CUDA and OptiX
      cudaPackages_12_6.cuda_cudart
      cudaPackages_12_6.cuda_cccl
    ];

  cmakeFlags = [
    "-DWITH_CYCLES_DEVICE_CUDA=${if cudaSupport then "ON" else "OFF"}"
    "-DWITH_CYCLES_DEVICE_OPTIX=ON"
    "-DWITH_CYCLES_NANOVDB=ON"
  ];

  meta = with lib; {
    description = "A C++ based, cross platform ray tracing library, exposed through ANARI.";
    homepage = "https://github.com/szellmann/anari-visionaray";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
