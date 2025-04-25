{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
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
  version = "v0.0.0-610-ga4bef0f";

  # Main source.
  src = fetchFromGitHub {
    owner = "szellmann";
    repo = "anari-visionaray";
    rev = "a4bef0f36cc680d620edbcc59f188a5dc492ba83";
    hash = "sha256-fyvi0H0Mj4SZpnvabde1zBrcnldkax/VBDdupmvIBbo=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/szellmann/anari-visionaray/commit/089e9d2e480a20a3fc03f42213156a6cc0f9c396.patch";
      hash = "sha256-DQlRxEUkQxO+vuT829TfYH6gsBkmNstTiqjb8T8rKC0=";
    })
  ];

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
