{
  boost,
  cmake,
  config,
  cudaSupport ? config.cudaSupport,
  cudaPackages,
  fetchFromGitHub,
  freeglut,
  lib,
  libjpeg,
  libpng,
  libtiff,
  openexr,
  ptex,
  stdenv,
  tbb_2021_11,
}:
stdenv.mkDerivation {
  pname = "visionaray";
  version = "v0.5.1";

  # Main source.
  src = fetchFromGitHub {
    owner = "szellmann";
    repo = "visionaray";
    rev = "82eb7935ba28f076463d0ec030971648c2d8ae83";
    hash = "sha256-/46S15kkhzKn4jAjcSOcMtxuOxoL0gtfX57jU3GNfpw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs =
    [
      cmake
    ]
    ++ lib.optionals cudaSupport [
      cudaPackages.cuda_nvcc
    ];

  propagatedBuildInputs = [
    boost
    tbb_2021_11
  ];

  buildInputs =
    [
      freeglut
      libjpeg
      libpng
      libtiff
      openexr
      ptex
    ]
    ++ lib.optionals cudaSupport [
      cudaPackages.cuda_cccl
      cudaPackages.cuda_cudart
    ];

  postUnpack = ''
    substituteInPlace \
      source/src/3rdparty/pbrt-parser/pbrtParser/impl/syntactic/FileMapping.h \
      --replace-fail "#include <string>" "#include <cstdint>\n#include <string>"
  '';

  postInstall = ''
    rm -fr ''${out}/lib/cmake/pbrtParser
  '';

  cmakeFlags = [
    "-DVSNRAY_ENABLE_PBRT_PARSER=ON"
    "-DVSNRAY_ENABLE_PTEX=ON"
    "-DVSNRAY_ENABLE_TBB=ON"
    "-DVSNRAY_ENABLE_EXAMPLES=OFF"
    "-DVSNRAY_ENABLE_VIEWER=OFF"
    "-DVSNRAY_ENABLE_COMMON=OFF"
    "-DVSNRAY_ENABLE_CUDA=${if cudaSupport then "ON" else "OFF"}"
  ];

  meta = with lib; {
    description = "A C++ based, cross platform ray tracing library.";
    homepage = "https://vis.uni-koeln.de/forschung/software-visionaray";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
