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
          dependencies = with pkgs; [
            fzf
            tree-sitter
            ripgrep #For nvim telescope grep_string to work
            fd # For nvim telescope to be faster

            # Formatters
            libxml2 # xmllint
            nixpkgs-fmt
            nodePackages.fixjson
            ruff
            shfmt
            stylua
            taplo # TOML formatter
            nodePackages.prettier
            google-java-format
            mdformat

            #Language servers
            basedpyright # python
            jdt-language-server # For java, the eclipse language server
            lombok # For jdt-language-server's lombok support
            lua-language-server
            nixd
            nodePackages.bash-language-server
            nodePackages.typescript-language-server
            terraform-ls
            astro-language-server
            vscode-langservers-extracted # HTML/CSS/JSON/ESLint language servers extracted from vscode
            tailwindcss-language-server

          ];
          custom-nvim = inputs.neovim-nightly-overlay.packages.${system}.default;
          custom-nvim-wrapper = (pkgs.symlinkJoin {
            name = "Benedek-Neovim";
            buildInputs = [ pkgs.makeWrapper ];
            paths = [ custom-nvim ] ++ dependencies;
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
