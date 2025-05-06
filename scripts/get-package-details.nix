{
  flake-path,
}:
with builtins;
let
  flake = builtins.getFlake (builtins.toString flake-path);
  allPackages =
    let
      uniquePackages =
        list: foldl' (acc: e: if elem e.name (catAttrs "name" acc) then acc else acc ++ [ e ]) [ ] list;
    in
    uniquePackages (concatMap attrValues (attrValues flake.outputs.packages));

  # Source types
  isGithub =
    p:
    (p ? "src" && p.src ? "url")
    && (match "(https://|ssh\+git://|git@)github.com/.*" p.src.url) != null;

  isPath = p: (p ? "src" && typeOf p.src == path);

  # Build default package details
  packageDetail = p: {
    definition = builtins.head (builtins.split '':[0-9]+'' p.meta.position);
    inherit (p) version;
  };

  # Path source package details
  pathPackageDetail =
    p:
    if (isPath p) then
      {
        sourcetype = "path";
        path = p.src;
      }
    else
      { };

  # Build github package details
  githubPackageDetail =
    p:
    if (isGithub p) then
      {
        sourcetype = "github";
        inherit (p.src) owner;
        inherit (p.src) repo;
        inherit (p.src) rev;
        hash = p.src.outputHash;
        inherit (p.src) url;
      }
      // (if p.src ? "tag" && p.src.tag != null then { inherit (p.src) tag; } else { })
      // (if p.src ? "branchName" && p.src.branchName != null then { ref = p.src.branchName; } else { })
    else
      { };
in
{
  # All packages
  details =
    let
      createDetail = p: packageDetail p // githubPackageDetail p // pathPackageDetail p;
    in
    listToAttrs (
      map (p: {
        name = p.pname;
        value = createDetail p;
      }) allPackages
    );
}
