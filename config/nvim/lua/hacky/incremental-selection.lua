_G.selected_node = {}

local keymapToIncrement = "😅"
local keymapToDecrement = "👍"
local function select_last_selected_node()
	if _G.selected_node[#_G.selected_node] == 0 then
		print("No selected node")
	end
	local start_row, start_col, end_row, end_col = _G.selected_node[#_G.selected_node]:range()
	-- print("parent: start_row " .. start_row .. "; start_col " .. start_col .. "; end_row " .. end_row .. "; end_col " .. end_col)
	vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
	vim.api.nvim_buf_set_mark(0, "<", start_row + 1, start_col, {})
	vim.api.nvim_buf_set_mark(0, ">", end_row + 1, end_col - 1, {})
	vim.cmd("normal! gv")
end

---@param node TSNode | nil Node at the given position
local function add_node(node)
	if not node then
		return
	end
	table.insert(_G.selected_node, node)
end

vim.keymap.set("n", keymapToIncrement, function()
	local node = vim.treesitter.get_node()
	add_node(node)
	select_last_selected_node()
end)

vim.keymap.set("v", keymapToIncrement, function()
	if _G.selected_node[#_G.selected_node] == 0 then
		add_node(vim.treesitter.get_node())
		select_last_selected_node()
		return
	end

	local parent = _G.selected_node[#_G.selected_node]:parent()

	if not parent then
		print("Root reached")
		return
	end

	add_node(parent)
	select_last_selected_node()
end)

vim.keymap.set("v", keymapToDecrement, function()
	if _G.selected_node[#_G.selected_node] == 0 then
		print("No selected node")
		return
	end

	table.remove(_G.selected_node)

	if _G.selected_node[#_G.selected_node] == 0 then
		print("No selected node")
		vim.cmd("normal! \27") -- \27 is <Esc>
		return
	end
	select_last_selected_node()
end)

local group = vim.api.nvim_create_augroup("TreesitterSelection", { clear = true })
vim.api.nvim_create_autocmd("ModeChanged", {
	group = group,
	pattern = "[vV\x16]*:*", -- leaving any visual mode (v, V, or <C-v>)
	callback = function()
		_G.selected_node = {}
	end,
})
