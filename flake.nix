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

            # Neovim plugins managed by Nix instead of Lazy.nvim
            vimPlugins.blink-cmp

          ];
          custom-nvim-wrapper = (pkgs.symlinkJoin {
            name = "Benedek-Neovim";
            buildInputs = [ pkgs.makeWrapper ];
            paths = [ pkgs.neovim ];
            postBuild = ''
              wrapProgram $out/bin/nvim \
                --set XDG_CONFIG_HOME "${./config}" \
                --set BLINK_CMP_PATH "${pkgs.vimPlugins.blink-cmp}" \
                --prefix PATH : "${pkgs.lib.makeBinPath dependencies}"
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

          # Some configs that I took from my previous configuration that might be helpful later:
          # home.sessionVariables = {
          #   EDITOR = "nvim";
          #   _NVIM_HELPER_LOCATION_OF_JAVA_JDTLS = pkgs.jdt-language-server;
          #   _NVIM_HELPER_LOCATION_OF_LOMBOK = "${pkgs.lombok}/share/java/lombok.jar"; # Needed for jdt-language-server
          # };
        };
    };
}
