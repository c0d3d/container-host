{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
    ./proxycontainers.nix
  ];

  services.openssh = {
    enable = true;
  };

  users.users.root.openssh.authorizedKeys.keyFiles = [ ~/.ssh/id_rsa.pub ];
  users.users.kyle.openssh.authorizedKeys.keyFiles = [ ~/.ssh/id_rsa.pub ];

  proxycontainers = {
    enable = true;
    containers = import ./containers.nix;
  };
  networking.firewall.allowedTCPPorts = [ 22 443 ];
}
