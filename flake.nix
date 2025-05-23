{
  description = "Zylo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # cimgui is in nixpkgs under "cimgui"
        buildInputs = with pkgs; [
          zig
          pkg-config
          lazygit
        ];
      in {
        devShell = pkgs.mkShell {
          inherit buildInputs;
          shellHook = ''
            alias la="eza -lA"
            echo "Zylo shell ready."
          '';
        };
      });
}

