-- Automatically change to the directory of the file or opened folder
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function(data)
		-- Only run if something was passed to nvim (a file or directory)
		if vim.fn.argc() == 0 then
			return
		end

		local path = data.file
		if not path or path == "" then
			return
		end

		-- Handle oil.nvim's URI format like "oil:///Users/foo/bar"
		if path:match("^oil://") then
			path = path:gsub("^oil://", "") -- strip the scheme
		end

		-- Expand to absolute path
		path = vim.fn.fnamemodify(path, ":p")

		local stat = vim.loop.fs_stat(path)
		if stat and stat.type == "directory" then
			-- Safely cd into the directory
			vim.fn.chdir(path)
		elseif stat and stat.type == "file" then
			-- Safely cd into the file’s parent directory
			local parent = vim.fn.fnamemodify(path, ":p:h")
			vim.fn.chdir(parent)
		end
	end,
})
