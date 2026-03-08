lib: _final: prev: {
  nvidia-mdl = lib.warnOnInstantiate "nvidia-mdl has been renamed to mdl-sdk to better follow upstream name usage" prev.mdl-sdk;
}
