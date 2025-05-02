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
  version = "v0.0.0-613-gea7d10e";

  # Main source.
  src = fetchFromGitHub {
    owner = "szellmann";
    repo = "anari-visionaray";
    rev = "ea7d10e795cd0f2d65f15ded575c8b3614d36e64";
    hash = "sha256-Ov/uHoiQLq9dW4pP4VvanhFhJPzqAhvMk5se5rtJhN4=";
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
