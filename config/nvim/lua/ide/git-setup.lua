
-- Find enclosing class/function names for code references.
local symbol_node_types = {
	class_declaration = true,
	class_definition = true,
	interface_declaration = true,
	enum_declaration = true,
	record_declaration = true,
	function_declaration = true,
	function_definition = true,
	function_item = true,
	method_declaration = true,
	method_definition = true,
	constructor_declaration = true,
}

local function enclosing_symbol(line)
	local source = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
	local column = math.max(0, source:find("%S") and source:find("%S") - 1 or 0)
	local ok, node = pcall(vim.treesitter.get_node, { bufnr = 0, pos = { line - 1, column } })
	if not ok or not node then
		return nil
	end

	local symbols = {}
	while node do
		if symbol_node_types[node:type()] then
			local name_node = node:field("name")[1]
			if name_node then
				table.insert(symbols, 1, vim.treesitter.get_node_text(name_node, 0))
			end
		end
		node = node:parent()
	end
	return #symbols > 0 and table.concat(symbols, ".") or nil
end

-- Copy repository-relative path and line range for sharing code references.
local function code_reference(first_line, last_line)
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		vim.notify("Cannot copy code reference: buffer has no file name", vim.log.levels.WARN)
		return
	end

	path = vim.fn.fnamemodify(path, ":p")
	local directory = vim.fn.fnamemodify(path, ":h")
	local root = vim.fs.root(directory, ".git")
	local base = root or vim.fn.getcwd()
	local relative_path = vim.fs.relpath(base, path)
	if not relative_path or relative_path == ".." or relative_path:sub(1, 3) == "../" then
		relative_path = path
	end
	local reference = relative_path .. ":" .. first_line
	if last_line ~= first_line then
		reference = reference .. "-" .. last_line
	end
	vim.fn.setreg("+", reference)
	vim.notify("Copied code reference: " .. reference)
end

vim.keymap.set("n", "<leader>yr", function()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	code_reference(line, line)
end, { desc = "Copy code reference" })

vim.keymap.set("x", "<leader>yr", function()
	local anchor_line = vim.fn.getpos("v")[2]
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	code_reference(math.min(anchor_line, cursor_line), math.max(anchor_line, cursor_line))
end, { desc = "Copy code reference for selection" })

local function copy_symbol_reference(line)
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		vim.notify("Cannot copy symbol reference: buffer has no file name", vim.log.levels.WARN)
		return
	end
	local symbol = enclosing_symbol(line)
	if not symbol then
		vim.notify("No enclosing class or function found", vim.log.levels.WARN)
		return
	end

	local filename = vim.fn.fnamemodify(path, ":t")
	local reference = symbol .. "(" .. filename .. ":" .. line .. ")"
	vim.fn.setreg("+", reference)
	vim.notify("Copied symbol reference: " .. reference)
end

vim.keymap.set("n", "<leader>ys", function()
	copy_symbol_reference(vim.api.nvim_win_get_cursor(0)[1])
end, { desc = "Copy symbol reference" })

vim.keymap.set("x", "<leader>ys", function()
	local anchor_line = vim.fn.getpos("v")[2]
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	copy_symbol_reference(math.min(anchor_line, cursor_line))
end, { desc = "Copy symbol reference" })

-- https://github.com/tpope/vim-fugitive
vim.keymap.set("n", "<leader>gb", ":<C-U>Git blame<CR>", { noremap = true, desc = "Open git blame", silent = true })
vim.keymap.set(
	"n",
	"<leader>gH",
	":<c-u>Git log --decorate --oneline --graph<cr>",
	{ noremap = true, desc = "Show commits for repository", silent = true }
)
vim.keymap.set(
	"n",
	"<leader>gh",
	":<c-u>Git log --decorate --oneline --graph %<cr>",
	{ noremap = true, desc = "Show commits that changed the file in buffer", silent = true }
)
vim.keymap.set("n", "<leader>gd", function()
	local commit_hash = vim.fn.getreg('"')
	vim.cmd("Gvdiffsplit " .. commit_hash)
end, { noremap = true, desc = "Compare file to its previous state in the commit in the clipboard", silent = true })

-- https://github.com/sindrets/diffview.nvim
require("diffview").setup({
	enhanced_diff_hl = true,
	view = {
		merge_tool = {
			layout = "diff3_mixed",
		},
	},
})
-- The file panel's file names link to `Normal`, which has no explicit fg here (the
-- transparent background setup clears it), so they fall back to the terminal's
-- foreground colour and become invisible on a light background.
vim.api.nvim_set_hl(0, "DiffviewFilePanelFileName", { fg = "#000000" })
vim.keymap.set(
	"n",
	"<leader>gv",
	":<c-u>DiffviewOpen<cr>",
	{ noremap = true, desc = "Diffview: working tree changes", silent = true }
)
vim.keymap.set("n", "<leader>gV", function()
	local commit_hash = vim.fn.getreg('"')
	vim.cmd("DiffviewOpen " .. commit_hash)
end, { noremap = true, desc = "Diffview: diff against the commit in the clipboard", silent = true })
vim.keymap.set(
	"n",
	"<leader>gf",
	":<c-u>DiffviewFileHistory %<cr>",
	{ noremap = true, desc = "Diffview: history of the file in buffer", silent = true }
)
vim.keymap.set(
	"n",
	"<leader>gF",
	":<c-u>DiffviewFileHistory<cr>",
	{ noremap = true, desc = "Diffview: history of the repository", silent = true }
)
vim.keymap.set(
	"n",
	"<leader>gq",
	":<c-u>DiffviewClose<cr>",
	{ noremap = true, desc = "Diffview: close", silent = true }
)

-- https://github.com/lewis6991/gitsigns.nvim
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				---@diagnostic disable-next-line: param-type-mismatch
				gitsigns.nav_hunk("next")
			end
		end, { noremap = true, silent = true, desc = "Next hunk" })

		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				---@diagnostic disable-next-line: param-type-mismatch
				gitsigns.nav_hunk("prev")
			end
		end, { noremap = true, silent = true, desc = "" })

		-- Actions
		map("n", "<leader>hs", gitsigns.stage_hunk, { noremap = true, silent = true, desc = "stage_hunk" })
		map("n", "<leader>hr", gitsigns.reset_hunk, { noremap = true, silent = true, desc = "reset_hunk" })

		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { noremap = true, silent = true, desc = "stage_hunk" })

		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { noremap = true, silent = true, desc = "reset_hunk" })

		map("n", "<leader>hS", gitsigns.stage_buffer, { noremap = true, silent = true, desc = "stage_buffer" })
		map("n", "<leader>hR", gitsigns.reset_buffer, { noremap = true, silent = true, desc = "reset_buffer" })
		map("n", "<leader>hp", gitsigns.preview_hunk, { noremap = true, silent = true, desc = "preview_hunk" })
		map(
			"n",
			"<leader>hi",
			gitsigns.preview_hunk_inline,
			{ noremap = true, silent = true, desc = "preview_hunk_inline" }
		)

		map("n", "<leader>hb", function()
			gitsigns.blame_line({ full = true })
		end, { noremap = true, silent = true, desc = "blame_line" })

		map("n", "<leader>hd", gitsigns.diffthis, { noremap = true, silent = true, desc = "diffthis" })

		map("n", "<leader>hD", function()
			---@diagnostic disable-next-line: param-type-mismatch
			gitsigns.diffthis("~")
		end, { noremap = true, silent = true, desc = "diffthis" })

		---@diagnostic disable-next-line: param-type-mismatch
		map("n", "<leader>hQ", function()
			gitsigns.setqflist("all")
		end, { noremap = true, silent = true, desc = "setqflist" })
		map("n", "<leader>hq", gitsigns.setqflist, { noremap = true, silent = true, desc = "setqflist" })

		-- Toggles
		map(
			"n",
			"<leader>tb",
			gitsigns.toggle_current_line_blame,
			{ noremap = true, silent = true, desc = "toggle_current_line_blame" }
		)
		map("n", "<leader>tw", gitsigns.toggle_word_diff, { noremap = true, silent = true, desc = "toggle_word_diff" })

		-- Text object
		map({ "o", "x" }, "ih", gitsigns.select_hunk, { noremap = true, silent = true, desc = "select_hunk" })
	end,
})
