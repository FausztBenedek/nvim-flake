-- To build nvim:
--
-- (the nix shell command does not work for some reason?)
-- nix-shell -p cmake gettext libtool automake ninja
-- make CMAKE_BUILD_TYPE=RelWithDebInfo  CMAKE_C_COMPILER=/opt/homebrew/opt/llvm/bin/clang  CMAKE_CXX_COMPILER=clang++=/opt/homebrew/opt/llvm/bin/clang++
-- sudo make install
--
-- And then to run it:
--
-- XDG_CONFIG_HOME=$(pwd)/config XDG_DATA_HOME=$(pwd)/data build/bin/nvim

------ OPTIONS ------
vim.g.mapleader = " "

-- line numbers
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
vim.opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.autoindent = true -- copy indent-- Create an autocommand group

vim.opt.wrap = false
vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

vim.opt.splitright = true -- split vertical window to the right
vim.opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
vim.opt.swapfile = false

-- Highlight the current line where the cursor is currently
vim.opt.cursorline = true
vim.opt.clipboard:append("unnamedplus") -- use system clipboard as default register

------ CORE KEYMAPS ------
vim.keymap.set(
	"n",
	"<leader><leader><leader>",
	":<c-u>source<CR>",
	{ noremap = true, silent = true, desc = "Sourcing the configuration" }
) -- Disables highlight
vim.keymap.set("n", "<Esc>", ":<c-u>nohlsearch<CR>", { noremap = true, silent = true }) -- Disables highlight
vim.keymap.set("n", "<C-q>", ":<c-u>q<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-b>", ":<c-u>Bdelete<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>", { noremap = false, silent = true })
vim.keymap.set("t", "<C-q>", "<C-\\><C-n>:<c-u>q!<cr>", { noremap = false, silent = true })
vim.keymap.set("t", "<C-b>", "<C-\\><C-n>:<c-u>bd!<cr>", { noremap = false, silent = true })
vim.keymap.set("n", "<C-t>", ":<c-u>25 sp | term<cr>i", { noremap = false, silent = true })

vim.keymap.set("n", "<C-n>", ":<c-u>tabn<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-p>", ":<c-u>tabp<cr>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-w><C-h>", "<C-w>H", { noremap = true, silent = true })
vim.keymap.set("n", "<C-w><C-j>", "<C-w>J", { noremap = true, silent = true })
vim.keymap.set("n", "<C-w><C-k>", "<C-w>K", { noremap = true, silent = true })
vim.keymap.set("n", "<C-w><C-l>", "<C-w>L", { noremap = true, silent = true })

vim.keymap.set("n", "<C-S-h>", "2<C-w><", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-j>", "2<C-w>+", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-k>", "2<C-w>-", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-l>", "2<C-w>>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

vim.keymap.set("t", "<C-w>", "<C-\\><C-n>", { noremap = true, silent = true })
vim.keymap.set("t", "<C-n>", "<C-\\><C-n>:tabn<cr>", { noremap = true, silent = true })
vim.keymap.set("t", "<C-p>", "<C-\\><C-n>:tabp<cr>", { noremap = true, silent = true })
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })

vim.keymap.set("n", "<C-d>", "mJA;<esc>`J", { noremap = true, silent = true })
vim.keymap.set("n", "<C-,>", "mJA,<esc>`J", { noremap = true, silent = true })
vim.keymap.set("i", "<C-d>", "<esc>mJA;<esc>`J", { noremap = true, silent = true })
vim.keymap.set("i", "<C-,>", "<esc>mJA,<esc>`J", { noremap = true, silent = true })

vim.keymap.set(
	"n",
	"<leader>sfj",
	":<c-u>set filetype=json<cr>:<c-u>set modifiable<cr>",
	{ noremap = true, silent = true, desc = ":set filetype=json" }
)
vim.keymap.set(
	"n",
	"<leader>sfl",
	":<c-u>set filetype=log<cr>",
	{ noremap = true, silent = true, desc = ":set filetype=log" }
)
vim.keymap.set(
	"n",
	"<leader>sfm",
	":<c-u>set filetype=markdown<cr>:<c-u>set modifiable<cr>",
	{ noremap = true, silent = true, desc = ":set filetype=markdown" }
)

-- English keyboard similarity maps
vim.api.nvim_set_keymap("n", "ú", "]", { noremap = false, silent = true }) -- must remain nvim_set_keymap, other does not work
vim.api.nvim_set_keymap("n", "ő", "[", { noremap = false, silent = true })
vim.keymap.set("n", "-", "/", { noremap = false, silent = true })
vim.keymap.set("n", "<C-y>", ":<c-u>normal! <cr>", { noremap = false, silent = true }) -- <C-a> (the original increment) is mapped on the system level to enter the tiling windon manager mode

------ PLUGINS ------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local opts = {}
local plugins = {
	-- Theme
	{ "https://github.com/catppuccin/nvim" },
	-- Plugins that are just added (no setup function needed)
	{ "https://github.com/itchyny/vim-qfedit" },
	{ "https://github.com/tpope/vim-surround" },
	{ "https://github.com/folke/which-key.nvim" },
	{ "https://github.com/tpope/vim-repeat" },
	{ "https://github.com/famiu/bufdelete.nvim" },
	{ "https://github.com/junegunn/vim-peekaboo" },
	{ "https://github.com/nvim-lua/plenary.nvim" }, -- neotest and buffer_manager depend on this
	{ "https://github.com/nvim-mini/mini.icons" }, -- oil.nvim depends on this
	{ "https://github.com/nvim-tree/nvim-web-devicons" }, -- oil.nvim depends on this
	{ "https://github.com/norcalli/nvim-colorizer.lua" },

	-- Plugins needing configuration (at least a setup function)
	{ "https://github.com/chiedo/vim-case-convert" },
	{ "https://github.com/lukas-reineke/indent-blankline.nvim" },
	{ "https://github.com/nvim-mini/mini.pick" },
	{ "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
	{ "https://github.com/stevearc/oil.nvim" },
	{ "https://github.com/windwp/nvim-autopairs" },
	{ "https://github.com/justinmk/vim-sneak" },
	{ "https://github.com/machakann/vim-highlightedyank" },
	{ "https://github.com/j-morano/buffer_manager.nvim" },

	--formatter-setup
	{ "https://github.com/mhartington/formatter.nvim" },

	-- git-setup
	{ "https://github.com/tpope/vim-fugitive" },
	{ "https://github.com/lewis6991/gitsigns.nvim" },

	--lsp-setup
	{ "https://github.com/neovim/nvim-lspconfig" },
	{
		-- Installed from nix, and the environment variable is also filled by the wrapper
		name = "blink.cmp",
		dir = vim.env.BLINK_CMP_PATH,
	},

	--runner-setup
	{ "https://github.com/stevearc/overseer.nvim.git" },

	--test-setup
	{ "https://github.com/antoinemadec/FixCursorHold.nvim" },
	{ "https://github.com/nvim-neotest/nvim-nio" },
	{ "https://github.com/nvim-neotest/neotest" },
	{ "https://github.com/nvim-neotest/neotest-python" },
	-- Other dependencies that are installed elsewhere
	-- { "https://github.com/nvim-treesitter/nvim-treesitter" },
}

require("lazy").setup(plugins, opts)

------ THEME ------
vim.cmd("colorscheme catppuccin-latte")

-- https://github.com/chiedo/vim-case-convert
vim.keymap.set("v", ",vc-", ":CamelToHyphen<CR>a", { noremap = false, silent = true, desc = "CamelToDash" })
vim.keymap.set("v", ",vc_", ":CamelToSnake<CR>a", { noremap = false, silent = true, desc = "CamelToSnake" })
vim.keymap.set("v", ",v-c", ":HyphenToCamel<CR>a", { noremap = false, silent = true, desc = "DashToCamel" })
vim.keymap.set("v", ",v-_", ":HyphenToSnake<CR>a", { noremap = false, silent = true, desc = "DashToSnake" })
vim.keymap.set("v", ",v_c", ":SnakeToCamel<CR>a", { noremap = false, silent = true, desc = "SnakeToCamel" })
vim.keymap.set("v", ",v_-", ":SnakeToHyphen<CR>a", { noremap = false, silent = true, desc = "SnakeToDash" })

-- https://github.com/lukas-reineke/indent-blankline.nvim
local hooks = require("ibl.hooks")
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
	-- create the highlight groups in the highlight setup hook, so they are reset
	-- every time the colorscheme changes
	vim.api.nvim_set_hl(0, "Indent1", { fg = "#51AFED" })
	vim.api.nvim_set_hl(0, "Indent2", { fg = "#3EB1BB" })
	vim.api.nvim_set_hl(0, "Indent3", { fg = "#3EBBA5" })
end)
require("ibl").setup({
	indent = {
		char = "┊",
		highlight = {
			"Indent1",
			"Indent2",
			"Indent3",
		},
	},
})

-- https://github.com/nvim-mini/mini.pick
require("mini.pick").setup({
	window = {
		config = function()
			local height = math.floor(0.9 * vim.o.lines)
			local width = math.floor(0.9 * vim.o.columns)
			return {
				anchor = "NW",
				height = height,
				width = width,
				row = math.floor(0.5 * (vim.o.lines - height)),
				col = math.floor(0.5 * (vim.o.columns - width)),
			}
		end,
	},
})
vim.keymap.set("n", "<leader>ff", function()
	require("mini.pick").builtin.files()
end, { noremap = false, silent = true, desc = "CamelToDash" })
vim.keymap.set("n", "<leader>fb", function()
	require("mini.pick").builtin.buffers()
end, { noremap = false, silent = true, desc = "CamelToDash" })
vim.keymap.set("n", "<leader>fs", function()
	require("mini.pick").builtin.grep()
end, { noremap = false, silent = true, desc = "CamelToDash" })

-- https://github.com/nvim-treesitter/nvim-treesitter
local treesitter_languages = {
	-- General
	"json",
	"yaml",
	"xml",
	"toml",
	"markdown",
	"markdown_inline",
	"bash",
	"dockerfile",
	"gitignore",
	-- Webdev
	"javascript",
	"typescript",
	"tsx",
	"html",
	"css",
	"scss",
	"svelte",
	"vue",
	"prisma",
	"astro",
	-- Neovim/vim related
	"lua",
	"vim",
	"query",
	"vimdoc",
	-- Other
	"java",
	"python",
	"rust",
	"nix",
}

vim.opt.runtimepath:prepend(vim.env.TREESITTER_PARSERS)
vim.g.ts_install = false
require("nvim-treesitter").setup({
	-- Directory to install parsers and queries to
	install_dir = vim.env.TREESITTER_PARSERS,
	highlight = { enable = true },
	indent = { enable = true },
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = treesitter_languages,
	callback = function()
		vim.treesitter.start()
	end,
})

-- https://github.com/stevearc/oil.nvim
require("oil").setup({
	default_file_explorer = true,
	keymaps = {
		["<C-v>"] = { "actions.select", opts = { vertical = true } },
		["<C-s>"] = { "actions.select", opts = { horizontal = true } },
		["<C-h>"] = false,
		["<C-l>"] = false,
	},
})
vim.keymap.set("n", "<c-e><c-e>", function()
	-- Using a callback, because vim.fn.getcwd() might change after startup
	vim.cmd("Oil " .. vim.fn.getcwd())
end, { noremap = true, silent = true })
vim.keymap.set("n", "<c-e><c-f>", ":<c-u>Oil<cr>", { noremap = true, silent = true })

-- https://github.com/windwp/nvim-autopairs
require("nvim-autopairs").setup({})

-- https://github.com/justinmk/vim-sneak
vim.keymap.set({ "n", "x", "o" }, "ű", "<Plug>Sneak_s", { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "o" }, "Ű", "<Plug>Sneak_S", { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "o" }, "f", "<Plug>Sneak_f", { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "o" }, "F", "<Plug>Sneak_F", { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "o" }, "t", "<Plug>Sneak_t", { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "o" }, "T", "<Plug>Sneak_T", { noremap = true, silent = true })

-- After lazy, sneak started map `s` even if I remapped it to disable, like the docs said. After setting and removing the issue is solved
vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>Sneak_s", { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>Sneak_S", { noremap = true, silent = true })
-- remove Sneak's default maps after load
vim.keymap.del({ "n", "x", "o" }, "s")
vim.keymap.del({ "n", "x", "o" }, "S")

-- https://github.com/machakann/vim-highlightedyank
vim.g.highlightedyank_highlight_duration = 300

-- https://github.com/j-morano/buffer_manager.nvim
require("buffer_manager").setup({
	width = 0.9,
	height = 0.9,
	show_indicators = "before",
	select_menu_item_commands = {
		v = {
			key = "<C-v>",
			command = "vsplit",
		},
		h = {
			key = "<C-s>",
			command = "split",
		},
	},
})
vim.keymap.set("n", "<leader>bb", function()
	require("buffer_manager.ui").toggle_quick_menu()
end, { noremap = true, silent = true, desc = "Toggle buffer manager menu" })
vim.keymap.set("n", "<leader>bs", function()
	require("buffer_manager.ui").save_menu_to_file()
end, { noremap = true, silent = true, desc = "Save buffer list to file" })
vim.keymap.set("n", "<leader>bl", function()
	require("buffer_manager.ui").save_menu_to_file()
end, { noremap = true, silent = true, desc = "Load buffer list from file" })

require("hacky.incremental-selection")
require("hacky.change-cwd")
require("ide.git-setup")
require("ide.lsp-setup")
require("ide.formatter-setup")
require("ide.runner-setup")
require("ide.test-setup") -- Depends on runner-setup (neotest uses overseer)
