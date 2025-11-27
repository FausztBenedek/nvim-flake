vim.pack.add({
	{ src = "https://github.com/stevearc/overseer.nvim.git" },
}, { confirm = false })

-- https://github.com/stevearc/overseer.nvim.git
require("overseer").setup({
	strategy = {
		"jobstart",
		use_terminal = false,
	},
	task_list = {
		bindings = {
			["<C-h>"] = false,
			["<C-j>"] = false,
			["<C-k>"] = false,
			["<C-l>"] = false,
			["<C-q>"] = "Close",
			["<c-p>"] = "PrevTask",
			["<c-n>"] = "NextTask",
			["<leader>q"] = "OpenQuickFix",
		},
	},
	task_launcher = {
		-- Set keymap to false to remove default behavior
		-- You can add custom keymaps here as well (anything vim.keymap.set accepts)
		bindings = {
			n = {
				["<c-q>"] = "Cancel",
				["<esc>"] = "Cancel",
			},
		},
	},
})
vim.keymap.set("n", "<leader>ro", ":<c-u>OverseerToggle<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rr", ":<c-u>OverseerRun<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rl", function()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks({ recent_first = true })
	if vim.tbl_isempty(tasks) then
		vim.notify("No tasks found", vim.log.levels.WARN)
	else
		overseer.run_action(tasks[1], "restart")
	end
end, { noremap = true, silent = true })
