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
          SDL2
          cimgui
          pkg-config
        ];
      in {
        devShell = pkgs.mkShell {
          inherit buildInputs;
          shellHook = ''
            echo "Zylo shell ready."
          '';
        };
      });
}

