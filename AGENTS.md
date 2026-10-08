# Agent instructions

## Validation

When a change could affect Neovim startup or runtime behavior (for example, Lua configuration, plugins, or Nix dependencies), consider checking startup headlessly from the repository root inside the Nix development shell:

```sh
nix develop .#dev --command nvim --headless '+qa!'
```

This check is advised when applicable, not mandatory for every change. Documentation-only changes generally do not need it, and there is no requirement to run it before editing.

Use the Nix-provided wrapper so the configuration and its dependencies are loaded. Avoid `--clean` or `-u NONE`, which bypass the configuration. Inspect both the exit status and output for startup errors. Report whether validation was performed and any failures or limitations; do not claim a check passed without running it.

The `dev` shell uses the live configuration in this checkout; the default shell uses a Nix-store snapshot. A successful startup is a smoke test, not proof that every affected feature works.

## Installation

The normal Neovim installation is managed by the Home Manager configuration in `~/.config/home-manager`:

- `flake.nix` declares the `benedek-neovim-flake` input from `github:FausztBenedek/nvim-flake`.
- `modules/cli/tools.nix` installs `inputs.benedek-neovim-flake.packages.${system}.default`.

Home Manager uses a locked flake input, not this live checkout. Local edits do not automatically update the installed Neovim. Deploying changes requires updating the Home Manager input and applying the appropriate Home Manager configuration.

Do not modify Home Manager files or activate a new configuration unless explicitly requested.
