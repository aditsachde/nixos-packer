# NixOS Packer Template

The configuration.nix works with the paritioning laid out in the packer build command. Adds a passwordless sudo user that can later be used by nixops to actually deploy the desired nixos config. The image should also automatically resize the root partition to match any disk size. 

```bash
packer build -var-file variables.json nixos.json 
```