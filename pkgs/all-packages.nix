self: pkgs:
let
  inherit (pkgs) callPackage;
in
{
  anari-barney = callPackage ./anari-barney {
    inherit (self) anari-sdk barney;
    nvidia-optix = self.nvidia-optix7;
  };
  anari-cycles = callPackage ./anari-cycles {
    inherit (self) anari-sdk;
    nvidia-optix = self.nvidia-optix7;
  };
  anari-ospray = callPackage ./anari-ospray {
    inherit (self)
      anari-sdk
      openvkl
      ospray
      rkcommon_0_14_2
      ;
  };
  anari-sdk = callPackage ./anari-sdk { inherit (self) webpconfig_cmake tinygltf; };
  anari-visionaray = callPackage ./anari-visionaray { inherit (self) anari-sdk visionaray; };
  barney = callPackage ./barney { nvidia-optix = self.nvidia-optix7; };
  cgns = callPackage ./cgns { };
  conduit = callPackage ./conduit { };
  hdanari = callPackage ./hdanari { inherit (self) anari-sdk; };
  nanovdb-tools = callPackage ./nanovdb-tools { };
  nixglenv = callPackage ./nixglenv { };
  nvidia-mdl = callPackage ./nvidia-mdl { };
  nvidia-nrd = callPackage ./nvidia-nrd { };
  nvidia-optix = callPackage ./nvidia-optix { };
  nvidia-optix7 = callPackage ./nvidia-optix7 { };
  nvidia-optix8 = callPackage ./nvidia-optix8 { };
  openvdb-tools = callPackage ./openvdb-tools { };
  openvkl = callPackage ./openvkl { inherit (self) rkcommon_0_14_2; };
  ospray = callPackage ./ospray { inherit (self) openvkl rkcommon_0_14_2; };
  pycgns = callPackage ./pycgns { };
  rkcommon_0_14_2 = callPackage ./rkcommon_0_14_2 { };
  tinygltf = callPackage ./tinygltf { };
  tsd = callPackage ./tsd { inherit (self) anari-sdk conduit; };
  visgl = callPackage ./visgl { inherit (self) anari-sdk; };
  visionaray = callPackage ./visionaray { };
  visrtx = callPackage ./visrtx {
    inherit (self) anari-sdk nvidia-mdl;
    nvidia-optix = self.nvidia-optix7;
  };
  webpconfig_cmake = callPackage ./webpconfig_cmake { };
}
