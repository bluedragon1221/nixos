{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:MarceColl/zen-browser-flake";
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        extra-substituters = ["https://ghostty.cachix.org"];
        extra-trusted-public-keys = ["ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="];
      };
      overlays = [
        (import ./packages inputs)
      ];
    };
  in {
    nixosConfigurations."collinux" = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs pkgs;};
      modules = [
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
        ./system
        ./home
      ];
    };

    packages.${system} =
      pkgs
      // {
        dependency-graph = pkgs.writeShellScriptBin "graph" ''
          cat <<EOF | ${pkgs.graphviz}/bin/dot -Tpng | kitten icat
          digraph {
            bgcolor="transparent"
            node [color="#cad3f5" fontcolor="#8aadf4"]
            edge [color="#cad3f5" dir=back]
            $(fd . packages -E "default.nix" | xargs -I{} -P10 sh -c '
              cat "{}" \
                | grep -zoE "^\{[^:]*\}:" \
                | tr -d "\n,:" \
                | tr "-" "_" \
                | xargs -0 printf "$(basename "{}" ".nix" | tr "-" "_") -> %s\n" &'
            )
          }
          EOF
        '';
      };
  };
}
