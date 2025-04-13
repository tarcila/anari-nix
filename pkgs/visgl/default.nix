{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  anari-sdk,
  libGL,
  pkg-config,
  python3,
}:
stdenv.mkDerivation {
  pname = "visgl";
  version = "v0.11.0-7-geed94dd";

  # Main source.
  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "VisRTX";
    rev = "eed94dd122db45236f57e05158f25184b0701c5d";
    hash = "sha256-wSa0W1GRz3LYY/KWVKwPBGq0Bh+10oggpQSFfmaEfos=";
  };

  cmakeFlags = [
    "-DVISRTX_BUILD_RTX_DEVICE=OFF"
    "-DVISRTX_BUILD_GL_DEVICE=ON"
    "-DVISRTX_PRECOMPILE_SHADERS=OFF"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  buildInputs = [
    anari-sdk
    libGL
  ];

  meta = with lib; {
    description = "VisRTX is an experimental, scientific visualization-focused implementation of the Khronos ANARI standard.";
    homepage = "https://github.com/NVIDIA/VisRTX";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
