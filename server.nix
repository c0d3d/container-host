{ ... }:
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
    ./proxycontainers.nix
  ];

  proxycontainers = {
    enable = true;
    containers = import ./containers.nix;
  };
}
