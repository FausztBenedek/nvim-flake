{
  description = "FausztBenedek's neovim config bundled";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    # It does not work within company firewalls, crates.io is not available
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

      perSystem = { pkgs, ... }:
        let
          tree-sitter-parsers = pkgs.symlinkJoin {
            name = "ts-parsers";
            paths = [
              pkgs.vimPlugins.nvim-treesitter
              pkgs.vimPlugins.nvim-treesitter-parsers.yaml
              pkgs.vimPlugins.nvim-treesitter-parsers.json
              pkgs.vimPlugins.nvim-treesitter-parsers.xml
              pkgs.vimPlugins.nvim-treesitter-parsers.toml
              pkgs.vimPlugins.nvim-treesitter-parsers.markdown
              pkgs.vimPlugins.nvim-treesitter-parsers.markdown_inline

              pkgs.vimPlugins.nvim-treesitter-parsers.bash
              pkgs.vimPlugins.nvim-treesitter-parsers.dockerfile
              pkgs.vimPlugins.nvim-treesitter-parsers.gitignore

              pkgs.vimPlugins.nvim-treesitter-parsers.javascript
              pkgs.vimPlugins.nvim-treesitter-parsers.typescript
              pkgs.vimPlugins.nvim-treesitter-parsers.tsx
              pkgs.vimPlugins.nvim-treesitter-parsers.css
              pkgs.vimPlugins.nvim-treesitter-parsers.html
              pkgs.vimPlugins.nvim-treesitter-parsers.scss
              pkgs.vimPlugins.nvim-treesitter-parsers.svelte
              pkgs.vimPlugins.nvim-treesitter-parsers.vue
              pkgs.vimPlugins.nvim-treesitter-parsers.prisma
              pkgs.vimPlugins.nvim-treesitter-parsers.astro

              pkgs.vimPlugins.nvim-treesitter-parsers.lua
              pkgs.vimPlugins.nvim-treesitter-parsers.vim
              pkgs.vimPlugins.nvim-treesitter-parsers.query
              pkgs.vimPlugins.nvim-treesitter-parsers.vimdoc

              pkgs.vimPlugins.nvim-treesitter-parsers.python
              pkgs.vimPlugins.nvim-treesitter-parsers.java
              pkgs.vimPlugins.nvim-treesitter-parsers.rust
              pkgs.vimPlugins.nvim-treesitter-parsers.nix
            ];
          };
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
            yaml-language-server

            # Neovim plugins managed by Nix instead of Lazy.nvim
            vimPlugins.blink-cmp

            # Java dev dependencies
            jdt-language-server
            lombok

          ];
          custom-nvim-wrapper = (pkgs.symlinkJoin {
            name = "Benedek-Neovim";
            buildInputs = [ pkgs.makeWrapper ];
            paths = [ pkgs.neovim ];
            postBuild = ''
              wrapProgram $out/bin/nvim \
                --set XDG_CONFIG_HOME "${./config}" \
                --set BLINK_CMP_PATH "${pkgs.vimPlugins.blink-cmp}" \
                --set TREESITTER_PARSERS "${tree-sitter-parsers}" \
                --set JAVA_JDTLS "${pkgs.jdt-language-server}" \
                --set LOMBOK_JAR "${pkgs.lombok}/share/java/lombok.jar" \
                --prefix PATH : "${pkgs.lib.makeBinPath dependencies}"
            '';
          });
          custom-nvim-dev-wrapper = (pkgs.symlinkJoin {
            name = "Benedek-Neovim";
            buildInputs = [ pkgs.makeWrapper ];
            paths = [ pkgs.neovim ];
            postBuild = ''
              wrapProgram $out/bin/nvim \
                --set XDG_CONFIG_HOME "/Users/benedekfauszt/.config/nvim-flake/config" \
                --set BLINK_CMP_PATH "${pkgs.vimPlugins.blink-cmp}" \
                --set TREESITTER_PARSERS "${tree-sitter-parsers}" \
                --set JAVA_JDTLS "${pkgs.jdt-language-server}" \
                --set LOMBOK_JAR "${pkgs.lombok}/share/java/lombok.jar" \
                --prefix PATH : "${pkgs.lib.makeBinPath dependencies}"
            '';
          });
        in
        {
          devShells.default = pkgs.mkShell {
            packages = [ custom-nvim-wrapper ];
          };

          # For tweaking the nvim configuration and receiving instant feedback
          devShells.dev = pkgs.mkShell {
            packages = [ custom-nvim-dev-wrapper ];
          };


          packages.default = custom-nvim-wrapper;
          packages.dev = custom-nvim-dev-wrapper;

          apps.default = {
            type = "app";
            program = "${custom-nvim-wrapper}/bin/nvim";
          };
        };
    };
}
