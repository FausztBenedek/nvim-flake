require("neotest").setup({
	consumers = {
		overseer = require("neotest.consumers.overseer"),
	},
	adapters = {
		require("neotest-python")({}),
		require("neotest-java")({
			junit_jar = nil, -- default: stdpath("data") .. /nvim/neotest-java/junit-platform-console-standalone-[version].jar
			incremental_build = true,
		}),
	},
})

-- neotest-java's incremental_build fires the jdtls build request but doesn't await it,
-- so test classes may not exist yet when the runner starts. For Java files we drive
-- compilation ourselves via jdtls.compile(), which accepts a real callback.
local function run_with_java_compile(run_fn)
  print("run_with_java_compile")
	if vim.bo.filetype == "java" then
		require("jdtls").compile("incremental", function(items)
			if #items == 0 then
				run_fn()
			else
				vim.notify("Java compilation failed (" .. #items .. " errors) — fix errors before running tests", vim.log.levels.WARN)
			end
		end)
	else
		run_fn()
	end
end

vim.keymap.set("n", "<leader>tr", function()
	run_with_java_compile(function() require("neotest").run.run() end)
end, { noremap = true, silent = true, desc = "Run current nearest test" })
vim.keymap.set("n", "<leader>ts", function()
	require("neotest").summary.toggle()
end, { noremap = true, silent = true, desc = "Toggle summary" })
vim.keymap.set("n", "<leader>tl", function()
	run_with_java_compile(function() require("neotest").run.run_last() end)
end, { noremap = true, silent = true, desc = "Run latest" })
vim.keymap.set("n", "<leader>to", function()
	require("neotest").output_panel.open()
end, { noremap = true, silent = true, desc = "Open test output" })
vim.keymap.set("n", "<leader>td", function()
	run_with_java_compile(function() require("neotest").run.run({ strategy = "dap" }) end)
end, { noremap = true, silent = true, desc = "Debug nearest test" })
