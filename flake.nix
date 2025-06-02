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
          wayland
          wayland-protocols
          libxkbcommon
          libdrm
          mesa
          pipewire
          libdecor
          dbus
          alsa-lib
          pulseaudio
          wlroots_0_18
          libglvnd
          wayland-scanner
          libusb1
          ibus
          libgbm
          xdg-utils
          xdg-desktop-portal
          xdg-desktop-portal-hyprland
          egl-wayland
        ];
      in {
        devShell = pkgs.mkShell {
          inherit buildInputs;
          shellHook = ''
            alias la="eza -lA"
            echo "Zylo dev shell ready."
            export LD_LIBRARY_PATH="${pkgs.dbus}/lib:${pkgs.libusb1}/lib:${pkgs.libglvnd}/lib:${pkgs.libdrm}/lib:${pkgs.mesa}/lib:${pkgs.libgbm}/lib:${pkgs.ibus}/lib:${pkgs.libdecor}/lib:${pkgs.wayland-protocols}/lib:${pkgs.egl-wayland}/lib:${pkgs.xdg-desktop-portal-hyprland}/lib:${pkgs.xdg-desktop-portal}/lib:${pkgs.xdg-utils}/lib:${pkgs.wayland}/lib:${pkgs.udev}/lib:$LD_LIBRARY_PATH"
          '';
        };
      });
}

