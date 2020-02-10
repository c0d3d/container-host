let
  vm =
    { config, pkgs, nodes, ... }:
    {
      deployment.targetEnv = "virtualbox";
      containers = {
        backend1 = {
          config = {
            services.darkhttpd = {
              enable = true;
              address = "all";
              rootDir = "${pkgs.valgrind.doc}/share/doc/valgrind/html";
            };
            networking.firewall.allowedTCPPorts = [ 80 ];
          };
          autoStart = true;
          privateNetwork = true;
          localAddress = "192.168.100.11";
          hostAddress = "192.168.100.10";
        };
        backend2 = {
          config = {
            services.darkhttpd = {
              enable = true;
              address = "all";
              rootDir = "${pkgs.nix.doc}/share/doc/nix/manual";
            };
            networking.firewall.allowedTCPPorts = [ 80 ];
          };
          autoStart = true;
          privateNetwork = true;
          localAddress = "192.168.100.12";
          hostAddress = "192.168.100.10";
        };
      };

      services.httpd.enable = true;
      services.httpd.adminAddr = "bob@example.org";
      services.httpd.extraModules = ["proxy_balancer" "lbmethod_byrequests"];
      services.httpd.extraConfig =
        ''
          <Proxy balancer://cluster>
            Allow from all
            BalancerMember http://192.168.100.11 retry=0
            BalancerMember http://192.168.100.12 retry=0
          </Proxy>
          ProxyPass         /    balancer://cluster/
          ProxyPassReverse  /    balancer://cluster/
        '';

      networking.firewall.allowedTCPPorts = [ 80 ];
    };

in {
  inherit vm;
}
