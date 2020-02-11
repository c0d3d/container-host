let
  containers = {
    valgrindm = {
      config = import ./valgrindmanual.nix;
    };
    nixm = {
      config = import ./nixmanual.nix;
    };
  };

in {
  vm = { pkgs, ... }: {
    imports = [ ./proxycontainers.nix ];
    deployment.targetEnv = "virtualbox";
    proxycontainers = {
      enable = true;
      inherit containers;
    };
    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
