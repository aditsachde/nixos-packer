{ config, pkgs, ... }:

{

  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "vmw_pvscsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.growPartition = true;

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
     git
   ];

  users.mutableUsers = false;
  users.users.packer = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys =
      [ "ssh public key" ];
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  
  system.stateVersion = "19.09"; # Do not change


  networking.firewall = {
    allowedTCPPorts = [ 80 443];
  };


  services.nginx = {
    enable = true;
    virtualHosts = {
      ## virtual host for Syapse
      "matrix.dangerousdemos.net" = {
        ## for force redirecting HTTP to HTTPS
        forceSSL = true;
        ## this setting takes care of all LetsEncrypt business
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8008";
        };
      };
    };
 
    ## other nginx specific best practices
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
  };

  services.matrix-synapse = {
    enable = true;

    ## domain for the Matrix IDs
    server_name = "dangerousdemos.net";

    ## enable metrics collection
    enable_metrics = true;

    ## enable user registration
    enable_registration = true;

    ## Synapse guys recommend to use PostgreSQL over SQLite
    database_type = "psycopg2";

    ## database setup clarified later
    database_args = {
      password = "synapse";
    };

    ## default http listener which nginx will passthrough to
    listeners = [
      {
        port = 8008;
        tls = false;
        resources = [
          {
            compress = true;
            names = ["client" "webclient" "federation"];
          }
        ];
      }
    ];
  };

  services.postgresql = {
    enable = true;

    ## postgresql user and db name remains in the
    ## service.matrix-synapse.database_args setting which
    ## by default is matrix-synapse
    initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
            TEMPLATE template0
            LC_COLLATE = "C"
            LC_CTYPE = "C";
        '';
  };
}
