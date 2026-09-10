{
  description = "My NixOS config — Hyprland laptop (i7-12700H + NVIDIA)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland from the flake — REQUIRED for hyprexpo
    hyprland.url = "github:hyprwm/Hyprland";

    # Official plugins (contains hyprexpo)
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    stylix.url = "github:nix-community/stylix";

  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprland-plugins, stylix, ... }@inputs:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/laptop/configuration.nix
        stylix.nixosModules.stylix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.ethan = import ./home/home.nix;
          home-manager.backupFileExtension = "hmbak";
        }
      ];
    };
  };
}
