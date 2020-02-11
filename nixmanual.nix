{ pkgs, ... }:
{
  services.darkhttpd = {
    enable = true;
    address = "all";
    rootDir = "${pkgs.nix.doc}/share/doc/nix/manual";
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
}
