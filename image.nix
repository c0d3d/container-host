{
  imports = [ <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix> ];
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keyFiles = [ ~/.ssh/id_rsa.pub ];
  networking.firewall.allowedTCPPorts = [ 22 ];
}
