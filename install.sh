#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
home_manager_dir="${HOME}/.config/home-manager"

if [[ ! -d "${home_manager_dir}" ]]; then
  printf 'Home Manager config not found: %s\n' "${home_manager_dir}" >&2
  exit 1
fi

printf 'Pushing Neovim config...\n'
git -C "${repo_root}" push

printf 'Updating benedek-neovim-flake and switching Home Manager...\n'
cd "${home_manager_dir}"
nix flake update benedek-neovim-flake
home-manager switch
