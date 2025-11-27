vim.pack.add({
  { src = 'https://github.com/mhartington/formatter.nvim' }
}, {confirm=false})

require("formatter").setup({
  -- https://github.com/mhartington/formatter.nvim/tree/master/lua/formatter
  filetype = {
    nix = {
      -- nixpkgs-fmt
      function()
        return {
          exe = "nixpkgs-fmt",
          args = { "--" },
          stdin = true,
        }
      end,
    },
    json = {
      require("formatter.filetypes.json").fixjson,
    },
    markdown = {
      function()
        return {
          exe = "mdformat",
          args = { "--wrap 80", "-" },
          stdin = true,
        }
      end,
    },
    xml = {
      require("formatter.filetypes.xml").xmllint,
    },
    html = {
      require("formatter.filetypes.html").prettier,
    },
    svg = {
      require("formatter.filetypes.xml").xmllint,
    },
    lua = {
      -- "formatter.filetypes.lua" defines default configurations for the
      -- "lua" filetype
      require("formatter.filetypes.lua").stylua,
    },
    terraform = {
      require("formatter.filetypes.terraform").terraformfmt,
    },
    typescript = {
      require("formatter.defaults.prettier"),
    },
    javascript = {
      require("formatter.defaults.prettier"),
    },
    vue = {
      require("formatter.defaults.prettier"),
    },
    svelte = {
      require("formatter.defaults.prettier"),
    },
    python = {
      require("formatter.filetypes.python").ruff,
    },
    java = {
      require("formatter.filetypes.java").google_java_format,
    },
    rust = {
      require("formatter.filetypes.rust").rustfmt,
    },
    toml = { -- align_entries was not an available option, so had to do it manually
      function()
        return {
          exe = "taplo",
          args = {
            "fmt",
            "--option align_entries=true",
            "-",
          },
          stdin = true,
        }
      end,
    },
    sh = {
      function()
        return {
          exe = "shfmt",
          stdin = true,
        }
      end,
    },
  },
})

-- Key mapping to manually trigger formatting
vim.api.nvim_set_keymap(
  "n",
  "<leader>ll",
  ":<c-u>Format<CR>",
  { noremap = true, silent = true, desc = "Formats the buffer's content" }
)






