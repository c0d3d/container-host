{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.proxycontainers;
in {
  options = {
    proxycontainers = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      containers = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            ip = mkOption {
              type = types.str;
            };
            config = mkOption {
              default = {};
            };
          };
        });
        default = {};
      };
    };
  };
  config = mkIf (cfg.enable) {
    containers = mapAttrs (name: value: {
      config = value.config; # TODO inherit config (value);
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = value.ip;
    }) cfg.containers;
    services.httpd = {
      enable = true;
      adminAddr = "kyle.sferrazza@gmail.com";
      virtualHosts = mapAttrs (name: value: {
        hostName = name;
        extraConfig = ''
          ProxyPass "/" "http://${value.ip}/"
          ProxyPassReverse "/" "http://${value.ip}/"
        '';
      }) cfg.containers;
      # TODO fallback page
      # virtualHosts.default = {
      # };
    };
  };
}
