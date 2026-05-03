local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Condition: "))
end, { desc = "DAP: Conditional breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP: Continue / start" })
vim.keymap.set("n", "<leader>ds", dap.step_over, { desc = "DAP: Step over" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP: Step into" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "DAP: Step out" })
vim.keymap.set("n", "<leader>dr", dap.restart, { desc = "DAP: Restart" })
vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "DAP: Terminate" })
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP: Run last" })
