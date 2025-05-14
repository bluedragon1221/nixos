{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil_ls = {
      # 52304da8e9748feff559ec90cb1f4873eda5cee1 = commit implementing the pipe operator
      url = "github:oxalica/nil/52304da8e9748feff559ec90cb1f4873eda5cee1";

      # or if you want the latest nil use this
      # url = "github:oxalica/nil/main";

      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    (import ./lib/nix-furnace {inherit inputs;}).mkFlake;
}
