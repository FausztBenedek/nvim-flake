{


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
        in
        {
          devShells.default = pkgs.mkShell {
            packages = [ custom-nvim ];
          };

          packages.default = custom-nvim;

          apps.default = {
            type = "app";
            program = "${custom-nvim}/bin/nvim";
          };
        };
    };
}
