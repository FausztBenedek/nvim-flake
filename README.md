# My personal neovim configuration

To start anywhere:

```sh
nix run --refresh github:FausztBenedek/nvim-flake
```

The only requirement is nix to be installed

- `--refresh` always checks wether new changes were pushed to the repo

# Development

To start up an isolated environment, in order to see, if all dependencies are
installed correctly.

```sh
nix develop --ignore-environment
```
