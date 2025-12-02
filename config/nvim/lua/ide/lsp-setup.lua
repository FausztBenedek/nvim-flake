-- LSP keymaps

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Show LSP definitions" }) -- show lsp definitions
vim.keymap.set("n", "grc", vim.lsp.buf.incoming_calls, { desc = "Show LSP incoming_calls in quickfixlist" }) -- show lsp implementations
vim.keymap.set({ "n", "v" }, "<leader>dh", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hint" })
vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show line diagnostics" }) -- show diagnostics for line
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic" }) -- jump to previous diagnostic in buffer
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic" }) -- jump to next diagnostic in buffer
vim.keymap.set("n", "<leader>ci", vim.lsp.buf.hover, { desc = "Show documentation for what is under cursor" }) -- show documentation for what is under cursor
vim.keymap.set("n", "<leader>crt", function()
	vim.cmd("g/import /d")
	vim.cmd("g/.spec.ts/d")
	vim.cmd("g/.spec.tsx/d")
	vim.cmd("g/UnitTest.java/d")
	vim.cmd("g/IntegrationTest.java/d")
end, {
	desc = "Remove test files and import from references quickfixlist",
	noremap = true,
	silent = true,
})

-- Lsp configs

vim.lsp.enable("basedpyright")
vim.lsp.enable("bashls")
vim.lsp.enable("astro")
vim.lsp.enable("ts_ls")
vim.lsp.enable("nixd")
vim.lsp.enable("terraformls")
vim.lsp.config("lua_ls", {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			print(path)
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using (most
				-- likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
				-- Tell the language server how to find Lua modules same way as Neovim
				-- (see `:h lua-module-load`)
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				-- library = {
				-- 	vim.env.VIMRUNTIME,
				-- 	-- My own hack for hacking away with my config
				-- 	vim.fn.stdpath("data") .. "/site/pack/core/opt",
				-- },
				-- Or pull in all of 'runtimepath'.
				-- NOTE: this is a lot slower and will cause issues when working on
				-- your own configuration.
				-- See https://github.com/neovim/nvim-lspconfig/issues/3189
				library = vim.api.nvim_get_runtime_file("", true),
			},
		})
	end,
	settings = {
		Lua = {},
	},
})
vim.lsp.enable("lua_ls")
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			diagnostics = {
				enable = false,
			},
		},
	},
})
vim.lsp.enable("rust_analyzer")
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- https://github.com/Saghen/blink.cmp
require("blink.cmp").setup({
	keymap = {
		["<C-z>"] = { "select_and_accept" },
	},

	-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
	-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
	-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
	--
	-- See the fuzzy documentation for more information
	--
	fuzzy = {
		implementation = "prefer_rust_with_warning",
		prebuilt_binaries = {
			force_version = "1.*",
		},
	},
})

-- java
local jdtls_group = vim.api.nvim_create_augroup("JdtlsSetup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = jdtls_group,
	pattern = "java",
	callback = function()
		require("ide.jdtls-setup").setup({})
	end,
})
