{
  lib,
  python3Packages,
  meson,
  fetchFromGitHub,
  stdenv,
  pkg-config,
  hdf5,
  ninja,
}:
let
  # Main source.
  src = fetchFromGitHub {
    owner = "pyCGNS";
    repo = "pyCGNS";
    rev = "6482d763e010f1bc1a0cbe737c9675f83a986411";
    hash = "sha256-VVd/uE19B9RNaR/gaMW5kZOoVTVDXb91EydKzdC1IO8=";
  };

in
stdenv.mkDerivation {
  pname = "pycgns";
  version = "v6.3.2-1-g6482d76";

  inherit src;

  nativeBuildInputs = [
    meson
    pkg-config
    python3Packages.cython
    ninja
  ];

  buildInputs = [
    python3Packages.numpy
    hdf5
  ];

  meta = with lib; {
    description = "pyCGNS is a set of Python modules implementing the CFD General Notation System standard.";
    homepage = "http://pycgns.github.io/";
    license = licenses.lgpl21Only;
    platforms = platforms.unix;
  };
}
