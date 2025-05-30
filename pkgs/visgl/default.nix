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
  version = "v0.11.0-103-g125b301";

  # Main source.
  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "VisRTX";
    rev = "125b301c60c5a5d4b7ad7784e1fcdfdc3599ea9a";
    hash = "sha256-dFfE5EHyBGVQxE7D4I+Aur+XiihIpAyHF7qWUoqESo0=";
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
