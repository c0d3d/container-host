{ pkgs, ... }:
{
  services.darkhttpd = {
    enable = true;
    address = "all";
    rootDir = "${pkgs.valgrind.doc}/share/doc/valgrind/html";
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
}
