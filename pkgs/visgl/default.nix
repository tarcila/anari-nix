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
  version = "v0.10.1-91-g1bef25d";

  # Main source.
  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "VisRTX";
    rev = "1bef25d1dc36538a1e55a3e8189e10f2c6ddeee8";
    hash = "sha256-+Ycd2n9bt+tNB5mmMF5SRarGXH8Wo0ucHvAANPLDPjA=";
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
