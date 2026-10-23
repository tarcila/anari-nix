{
  anari-sdk,
  cmake,
  apple-sdk_14,
  fetchFromGitHub,
  lib,
  python3,
  stdenv,
  openusd,
  opensubdiv,
  materialx,
  libGL,
  libx11,
  libxt,
  tbb,
  imath,
  nix-update-script,
}:
stdenv.mkDerivation {
  pname = "anari-usd";
  version = "0.16.0-unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "NVIDIA-Omniverse";
    repo = "ANARI-USD";
    rev = "26da9e90c2f98aabbb9249ee6805428c0c2175a9";
    hash = "sha256-LBqUvf2XkOH8c8RKBwyN6zXOcP6MbYFxJP+kPEpOLIE=";
  };

  patches = [
    ./0001-Use-find-components-instead-of-explicitely-iterating.patch
    ./0002-Find-X11-and-OpenGL-as-dependencies-of-OpenUSD-Mater.patch
    ./0003-Also-skip-gomp-when-flattening-usd-libraries.patch
    ./0004-Also-ignore-static-and-dylib-libraries.patch
    ./0005-Fix-build-on-MacOS.patch
    ./0006-Let-USD-find-OpenSubdiv-in-config-mode.patch
  ];

  nativeBuildInputs = [
    cmake
    python3
  ];

  buildInputs = [
    anari-sdk
    imath
    materialx
    openusd
    opensubdiv
    tbb
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    # What's need for MaterialX on Linux
    libx11
    libxt
    libGL
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_14
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };

  meta = with lib; {
    description = "HdAnari is USD Hydra Render delegate enabling the use of ANARI devices inside USD.";
    homepage = "https://www.khronos.org/anari/";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
