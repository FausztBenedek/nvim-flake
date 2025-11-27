{
  description = "FausztBenedek's neovim config bundled";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "default"
        "default-linux"
        "default-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem = { pkgs, system, ... }:
        let
          custom-nvim = inputs.neovim-nightly-overlay.packages.${system}.default;
          custom-nvim-wrapper = (pkgs.symlinkJoin {
            name = "Benedek-Neovim";
            buildInputs = [ pkgs.makeWrapper ];
            paths = [ custom-nvim ];
            postBuild = ''
              wrapProgram $out/bin/nvim --set XDG_CONFIG_HOME "${./config}"
            '';
          });
        in
        {
          devShells.default = pkgs.mkShell {
            packages = [ custom-nvim-wrapper ];
          };

          packages.default = custom-nvim-wrapper;

          apps.default = {
            type = "app";
            program = "${custom-nvim-wrapper}/bin/nvim";
          };
        };
    };
}
