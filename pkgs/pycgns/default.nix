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
    rev = "4326faf2c4fc03c4fc23c55629013c275fd5042b";
    hash = "sha256-3GSTffTIcu7o5t18UIHyjXahC5Rj9z6bUQG8aNRenDA=";
  };

in
stdenv.mkDerivation {
  pname = "pycgns";
  version = "v6.3.2";

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
