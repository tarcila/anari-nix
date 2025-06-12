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
  version = "v0.11.0-129-g4b5e9fe";

  # Main source.
  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "VisRTX";
    rev = "4b5e9fef22a7310b004c160d4f8dd33b36458fb2";
    hash = "sha256-oaK0qkePkcvFuWlH2otvaMg/BbkAgRh7wdFlRPpADiU=";
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
