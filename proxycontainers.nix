{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.proxycontainers;
  startIp = 11;
  makeIp = num: "192.168.100.${toString num}";
  addIps = (set:
    let
      names = builtins.attrNames set;
      folded = lib.lists.foldr (cur: acc:
        let
          val = builtins.getAttr cur set;
          newVal = val // { ip = makeIp acc.idx; };
          newItems = acc.items // { "${cur}" = newVal; };
          newIdx = acc.idx + 1;
        in { items = newItems; idx = newIdx; }
        ) { idx = startIp; items = {}; } names;
    in folded.items
  );
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
  config = mkIf (cfg.enable)
  (let
    withIps = addIps cfg.containers;
  in {
    containers = mapAttrs (name: value: {
      config = value.config; # TODO inherit config (value);
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = "${value.ip}";
    }) withIps;
    services.httpd = {
      enable = true;
      adminAddr = "kyle.sferrazza@gmail.com";
      virtualHosts = mapAttrs (name: value: {
        hostName = name;
        extraConfig = ''
          ProxyPass "/" "http://${value.ip}/"
          ProxyPassReverse "/" "http://${value.ip}/"
        '';
      }) withIps;
      # TODO fallback page
      # virtualHosts.default = {
      # };
    };
  });
}
