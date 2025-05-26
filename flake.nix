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
          cmake
          wayland.dev
          wayland-protocols
          libxkbcommon
          libdrm
          mesa
          pkg-config
          pipewire
          xorg.libX11
          xorg.libXext
          xorg.libXrandr
          xorg.libXcursor
          dbus
          alsa-lib
          pulseaudio
          wlroots_0_18
          libglvnd
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          xorg.libXxf86vm
          wayland-scanner
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

