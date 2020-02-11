{ pkgs, ... }:
let
  proxycontainers = builtins.fetchGit {
    url = "https://github.com/kylesferrazza/proxycontainers.git";
    rev = "25b7c343dafef9047fb85b0343d3dcf84c1f2175";
    ref = "master";
  };
in {
  imports = [
    <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
    "${proxycontainers}"
  ];

  proxycontainers = {
    enable = true;
    containers = import ./containers.nix;
    sslServerCert = ../nix-gce/cert.pem;
    sslServerChain = ../nix-gce/fullchain.pem;
    sslServerKey = ../nix-gce/privkey.pem;
  };
}
