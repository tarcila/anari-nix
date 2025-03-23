{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  spirv-headers,
  directx-shader-compiler,
  cmakeCurses,
}:
let
  version = "v4.14.3";
  src = fetchFromGitHub {
    owner = "NVIDIA-RTX";
    repo = "NRD";
    rev = version;
    hash = "sha256-oQmLUN5Bh485+Zu8VxW38aiEpVNfkCCD//4MgjxQYD0=";
    fetchSubmodules = true;
  };

  mathlib_src = fetchFromGitHub {
    name = "mathlib-src";
    owner = "NVIDIA-RTX";
    repo = "MathLib";
    rev = "9888e8e56b4b24b853e83e91209db868d1b008a7";
    hash = "sha256-RekwH2hONuh1pmJ1PZX2tdRg8llCTuxasWXzZ4xJTOk=";
  };

  shadermake_src = fetchFromGitHub {
    name = "shadermake-src";
    owner = "NVIDIA-RTX";
    repo = "ShaderMake";
    rev = "c8573cbe0621d64932e09dc3146863be83502950";
    hash = "sha256-8Jv4BMgvAo331PpqCXRnnnIo/LkNoEfXWNeA0hbtYFw=";
  };
in
stdenv.mkDerivation {
  inherit src version;
  pname = "nrd";

  cmakeFlags = [
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DFETCHCONTENT_BASE_DIR=/build/"
  ];

  nativeBuildInputs = [
    cmake
    cmakeCurses
  ];

  buildInputs = [
    spirv-headers
    directx-shader-compiler
  ];

  sourceRoot = "source";

  srcs = [
    src
    mathlib_src
    shadermake_src
  ];

  installPhase = ''
    mkdir -p $out/{include/NRD/shader,lib}
    cp -r ${src}/Include $out/include/NRD/
    cp -r ${src}/Shaders/Include/ $out/include/NRD/shaders/
    cp libNRD.so $out/lib/
  '';

  meta = with lib; {
    description = "NVIDIA Real-Time Denoisers (NRD) is a spatio-temporal API agnostic denoising library.";
    homepage = "https://github.com/NVIDIAGameWorks/RayTracingDenoiser";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
