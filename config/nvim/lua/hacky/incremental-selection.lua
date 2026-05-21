---@type TSNode[]
_G.selected_node = {}

local keymapToIncrement = "😅"
local keymapToDecrement = "👍"


local function get_node()
  return vim.treesitter.get_node()

end
local function get_relevant_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local start_line, start_col = start_pos[2], start_pos[3]
	local end_line, end_col = end_pos[2], end_pos[3]

end

local function select_last_selected_node()
	if #_G.selected_node == 0 then
		vim.notify("No selected node", vim.log.levels.INFO)
	end
	local start_row, start_col, end_row, end_col = _G.selected_node[#_G.selected_node]:range()

	start_pos = { math.min(vim.api.nvim_buf_line_count(0), start_row + 1), start_col }
	end_pos = { math.min(vim.api.nvim_buf_line_count(0), end_row + 1), math.max(0, end_col - 1) }

	-- print(
	-- 	"parent: start_row "
	-- 		.. start_pos[1]
	-- 		.. "; start_col "
	-- 		.. start_pos[2]
	-- 		.. "; end_row "
	-- 		.. end_pos[1]
	-- 		.. "; end_col "
	-- 		.. end_pos[2]
	-- )

	vim.api.nvim_win_set_cursor(0, start_pos)
	vim.api.nvim_buf_set_mark(0, "<", start_pos[1], start_pos[2], {})
	vim.api.nvim_buf_set_mark(0, ">", end_pos[1], end_pos[2], {})
	vim.cmd("normal! gvo")
end

---@param node TSNode | nil Node at the given position
local function add_node(node)
	if not node then
		return
	end

	if #_G.selected_node > 0 and vim.deep_equal({ _G.selected_node[#_G.selected_node]:range() }, { node:range() }) then
		-- print(
		-- 	"skipping node "
		-- 		.. node:type()
		-- 		.. " range: "
		-- 		.. vim.inspect({ node:range() })
		-- 		.. " because it has the same range as its child"
		-- )
		add_node(node:parent())
		return
		-- else
		-- 	print(
		-- 		"Add node "
		-- 			.. node:type()
		-- 			.. " parent range: "
		-- 			.. (#_G.selected_node == 0 and "none" or vim.inspect({ _G.selected_node[#_G.selected_node]:range() }))
		-- 			.. " node range: "
		-- 			.. vim.inspect({
		-- 				node:range(),
		-- 			})
		-- 	) -- To investigate the steps in the tree
	end
	table.insert(_G.selected_node, node)
end

local function next_sibling()
	if #_G.selected_node == 0 then
		return
	end

	local sibling = _G.selected_node[#_G.selected_node]:next_named_sibling()
	if not sibling then
		return
	end
	_G.selected_node = { sibling }
  select_last_selected_node()
end

local function prev_sibling()
	if #_G.selected_node == 0 then
		return
	end

	local sibling = _G.selected_node[#_G.selected_node]:prev_named_sibling()
	if not sibling then
		return
	end
	_G.selected_node = { sibling }
  select_last_selected_node()
end

vim.keymap.set("n", keymapToIncrement, function()
	local node = vim.treesitter.get_node()
	add_node(node)
	select_last_selected_node()
end)

vim.keymap.set("v", keymapToIncrement, function()
	if #_G.selected_node == 0 then
		add_node(vim.treesitter.get_node())
		select_last_selected_node()
		return
	end

	local parent = _G.selected_node[#_G.selected_node]:parent()

	if not parent then
		vim.notify("Cannot increment selection: Root selected", vim.log.levels.INFO)
		return
	end

	add_node(parent)
	select_last_selected_node()
end)

vim.keymap.set("v", keymapToDecrement, function()
	if #_G.selected_node == 0 then
		vim.notify("Cannot decrement selection: Starting point reached", vim.log.levels.INFO)
		return
	end

	table.remove(_G.selected_node)

	if #_G.selected_node == 0 then
		vim.notify("Cannot decrement selection any more: Starting point reached", vim.log.levels.INFO)
		vim.cmd("normal! \27") -- \27 is <Esc>
		return
	end
	select_last_selected_node()
end)

vim.keymap.set("v", "😊", next_sibling, { noremap = true, desc = "Select the next sibling" })
vim.keymap.set("v", "🍆", prev_sibling, { noremap = true, desc = "Select the previous sibling" })

local group = vim.api.nvim_create_augroup("TreesitterSelection", { clear = true })
vim.api.nvim_create_autocmd("ModeChanged", {
	group = group,
	pattern = "[vV\x16]*:*", -- leaving any visual mode (v, V, or <C-v>)
	callback = function()
		_G.selected_node = {}
	end,
})
