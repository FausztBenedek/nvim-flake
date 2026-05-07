local M = {}
local function is_openapi_buffer(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 40, false)

	for _, line in ipairs(lines) do
		if line:match("^openapi:") or line:match([["openapi"%s*:]]) then
			return true
		end
	end

	return false
end
local function openapi_references()
	-- Step 1: Get the schema name under the cursor
	local word = vim.fn.expand("<cword>")
	local ref = "#/components/schemas/" .. word

	-- Step 2: Use ripgrep to find all references to this schema
	local cmd = "rg --vimgrep "
		.. "--glob '*.yaml' "
		.. "--glob '*.yml' "
		.. "--glob '*.json' "
		.. vim.fn.shellescape(ref .. "\\b")

	local raw_lines = vim.fn.systemlist(cmd)
	local qf_items = {}

	-- Step 3: Process each ripgrep result
	for _, line in ipairs(raw_lines) do
		-- vimgrep format: filename:lnum:col:text
		local filename, lnum_str, col_str, text = line:match("^(.+):(%d+):(%d+):(.*)$")

		if filename and lnum_str then
			local lnum = tonumber(lnum_str)
			local col = tonumber(col_str)

			-- Step 4: Read the file and walk backwards to find the parent schema name
			local file_lines = vim.fn.readfile(filename)
			local parent = nil
			local match_indent = #(file_lines[lnum]:match("^(%s*)") or "")
			local last_indent = match_indent

      -- Lua for loop: for i = start, stop, step do
			for i = lnum - 1, 1, -1 do
				local l = file_lines[i]
				local indent = #(l:match("^(%s*)") or "")

				-- Only look at lines that are less indented than the last find
				if indent < last_indent then
					local schema_name = l:match("^%s*([%w_]+)%s*:") -- YAML bare key
						or l:match('^%s*"([%w_]+)"%s*:') -- JSON quoted key

					if schema_name then
						-- Stop if we've reached structural OpenAPI keys
						if schema_name == "schemas" or schema_name == "components" or schema_name == "definitions" then
							break
						end
						-- Otherwise this is our new best candidate, keep walking up
						parent = schema_name
						last_indent = indent
					end
				end
			end

			-- Step 5: Build the quickfix entry with the parent schema name prepended
			table.insert(qf_items, {
				filename = filename,
				lnum = lnum,
				col = col,
				text = (parent and ("[" .. parent .. "] ") or "") .. text:gsub("^%s+", ""),
			})
		end
	end

	-- Step 6: Populate and open the quickfix list
	vim.fn.setqflist({}, " ", {
		title = "OpenAPI References: " .. word,
		items = qf_items,
	})
	vim.cmd("copen")
end

local function openapi_jump_to_definition()
	-- Get the word/path under cursor (grab the full line and extract the ref)
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1

	-- Find the $ref pattern around cursor position
	local ref = line:match("#/components/schemas/([%w_]+)", 1)
	if not ref then
		-- Try matching from cursor vicinity more loosely
		ref = line:match("['\"]?#/components/schemas/([%w_]+)['\"]?")
	end

	if not ref then
		vim.notify("No OpenAPI $ref found on this line", vim.log.levels.WARN)
		return
	end

	vim.notify("Jumping to: " .. ref, vim.log.levels.INFO)

	-- Search the buffer for the definition
	-- In YAML: "BiproPayload:" at the top level under components.schemas
	-- In JSON: "BiproPayload":
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	for i, l in ipairs(lines) do
		-- Match YAML key like `    BiproPayload:` or JSON `"BiproPayload":`
		if l:match("^%s+" .. vim.pesc(ref) .. "%s*:") or l:match('"' .. vim.pesc(ref) .. '"%s*:') then
			-- Save current position to jumplist before jumping
			vim.cmd("normal! m'")

			vim.api.nvim_win_set_cursor(0, { i, 0 })
			vim.cmd("normal! zz^") -- center screen
			return
		end
	end

	vim.notify("Definition not found for: " .. ref, vim.log.levels.WARN)
end

function M.attach_openapi_maps(bufnr)
	if not is_openapi_buffer(bufnr) then
		return
	end

	local opts = { buffer = bufnr, silent = true }

	vim.keymap.set("n", "gd", openapi_jump_to_definition, opts)
	vim.keymap.set("n", "grr", openapi_references, opts)
end

return M
