let
  vm =
    { pkgs, ... }:
    {
      deployment.targetEnv = "virtualbox";
      containers = {
        backend1 = {
          config = import ./valgrindmanual.nix;
          autoStart = true;
          privateNetwork = true;
          localAddress = "192.168.100.11";
          hostAddress = "192.168.100.10";
        };
        backend2 = {
          config = import ./nixmanual.nix;
          autoStart = true;
          privateNetwork = true;
          localAddress = "192.168.100.12";
          hostAddress = "192.168.100.10";
        };
      };

      services.httpd = {
        enable = true;
        adminAddr = "kyle.sferrazza@gmail.com";
        virtualHosts = {
          valgrindmanual = {
            hostName = "valgrindmanual";
            extraConfig = ''
              ProxyPass "/" "http://192.168.100.11/"
              ProxyPassReverse "/" "http://192.168.100.11/"
            '';
          };
          nixmanual = {
            hostName = "nixmanual";
            extraConfig = ''
              ProxyPass "/" "http://192.168.100.12/"
              ProxyPassReverse "/" "http://192.168.100.12/"
            '';
          };
          #default = {

          #};
        };

      };
      networking.firewall.allowedTCPPorts = [ 80 ];
    };

in {
  inherit vm;
}
