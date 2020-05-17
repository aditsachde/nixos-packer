{ config, pkgs, ... }:

{

  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "vmw_pvscsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.growPartition = true;
  nix.maxJobs = "auto";

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = false;
  networking.interfaces.ens192.useDHCP = true;

  virtualisation.vmware.guest.enable = true;
  virtualisation.vmware.guest.headless = true;

  environment.systemPackages = with pkgs; [
     git jq
   ];

  users.mutableUsers = false;
  users.users.deploy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys =
      [ "ssh public key" ];
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = [ "root" "deploy" ];

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  
  nixpkgs.config.allowUnfree = true;
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ "network id" ];

  system.stateVersion = "20.03"; # Do not change

}
