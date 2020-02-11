let
  containers = {
    "valgrindm.test.kylesferrazza.com" = {
      config = import ./valgrindmanual.nix;
    };
    "nixm.test.kylesferrazza.com" = {
      config = import ./nixmanual.nix;
    };
  };

in {
  vm = { pkgs, ... }: {
    imports = [ ./proxycontainers.nix ];

    # TODO deploy this to GCE
    deployment.targetEnv = "virtualbox";
    proxycontainers = {
      enable = true;
      inherit containers;
    };
    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
