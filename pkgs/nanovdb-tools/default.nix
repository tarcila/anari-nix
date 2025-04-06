{
  boost,
  config,
  cudaPackages,
  cudaSupport ? config.cudaSupport,
  c-blosc,
  cmake,
  fetchFromGitHub,
  fetchpatch,
  jemalloc,
  lib,
  openvdb,
  stdenv,
  tbb,
  zlib,
}:
let
  # Main source.
  version = "v12.0.1";
  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = "openvdb";
    rev = version;
    hash = "sha256-ofVhwULBDzjA+bfhkW12tgTMnFB/Mku2P2jDm74rutY=";
  };
in
stdenv.mkDerivation {
  inherit src version;

  pname = "nanovdb-tools";

  nativeBuildInputs =
    [
      cmake
    ]
    ++ lib.optionals cudaSupport [
      cudaPackages.cuda_nvcc
    ];

  buildInputs =
    [
      boost
      c-blosc
      jemalloc
      openvdb
      tbb
      zlib
    ]
    ++ lib.optionals cudaSupport [
      cudaPackages.cuda_cudart
    ];

  cmakeFlags =
    [
      "-DNANOVDB_BUILD_TOOLS=ON"
      "-DNANOVDB_USE_OPENVDB=ON"
      "-DOPENVDB_BUILD_BINARIES=ON"
      "-DOPENVDB_BUILD_CORE=OFF"
      "-DOPENVDB_BUILD_VDB_PRINT=OFF"
      "-DUSE_NANOVDB=ON"
    ]
    ++ lib.optionals cudaSupport [
      "-DNANOVDB_USE_CUDA=ON"
    ];

  meta = with lib; {
    description = "Open framework for voxel (NanoVDB tools)";
    homepage = "https://software.llnl.gov/conduit/";
    license = licenses.bsd0;
    platforms = platforms.unix;
  };
}
