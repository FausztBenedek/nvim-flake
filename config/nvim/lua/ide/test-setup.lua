require("neotest").setup({
	consumers = {
		overseer = require("neotest.consumers.overseer"),
	},
	adapters = {
		require("neotest-python")({}),
	},
})

vim.keymap.set("n", "<leader>tr", function()
	require("neotest").run.run()
end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ts", function()
	require("neotest").summary.toggle()
end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>tl", function()
	require("neotest").run.run_last()
end, { noremap = true, silent = true })
