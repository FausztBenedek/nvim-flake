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

vim.keymap.set("n", "<leader>tr", function()
	require("neotest").run.run()
end, { noremap = true, silent = true, desc = "Run current nearest test" })
vim.keymap.set("n", "<leader>ts", function()
	require("neotest").summary.toggle()
end, { noremap = true, silent = true, desc = "Toggle summary" })
vim.keymap.set("n", "<leader>tl", function()
	require("neotest").run.run_last()
end, { noremap = true, silent = true, desc = "Run latest" })
