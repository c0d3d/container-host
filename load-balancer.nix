let
  containers = {
    backend1 = {
      ip = "192.168.100.11";
      config = import ./valgrindmanual.nix;
    };
    backend2 = {
      ip = "192.168.100.12";
      config = import ./nixmanual.nix;
    };
  };

in {
  vm = { pkgs, ... }: {
    imports = [ ./container.nix ];
    deployment.targetEnv = "virtualbox";
    proxycontainers = {
      enable = true;
      inherit containers;
    };
    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
