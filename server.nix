{ ... }:
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
    ./proxycontainers.nix
  ];
  users.users.root.openssh.authorizedKeys.keyFiles = [ ~/.ssh/id_rsa.pub ];

  proxycontainers = {
    enable = true;
    containers = import ./containers.nix;
  };
}
