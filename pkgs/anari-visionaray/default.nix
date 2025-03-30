{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  config,
  cudaSupport ? config.cudaSupport,
  cudaPackages_12_6,
  anari-sdk,
  python3,
  visionaray,
}:
stdenv.mkDerivation {
  pname = "anari-visionaray";
  version = "v0.0.0-598-g22b9a7c";

  # Main source.
  src = fetchFromGitHub {
    owner = "szellmann";
    repo = "anari-visionaray";
    rev = "22b9a7cecd5fc6bdb66c0471b8ac7ae86674b3be";
    hash = "sha256-Wf4GB8w8y+AgwQYwyxqbeD0bskehf4m2WXJJooeW3V4=";
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
      visionaray
    ]
    ++ lib.optionals cudaSupport [
      # CUDA and OptiX
      cudaPackages_12_6.cuda_cudart
      cudaPackages_12_6.cuda_cccl
    ];

  cmakeFlags = [
    "-DANARI_VISIONARAY_ENABLE_CUDA=${if cudaSupport then "ON" else "OFF"}"
    "-DANARI_VISIONARAY_ENABLE_NANOVDB=ON"
  ];

  meta = with lib; {
    description = "A C++ based, cross platform ray tracing library, exposed through ANARI.";
    homepage = "https://github.com/szellmann/anari-visionaray";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
