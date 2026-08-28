-- https://github.com/mfussenegger/nvim-dap
--
-- debugpy comes from nix (flake.nix sets DEBUGPY_PYTHON) and is used *only* to run the
-- adapter. The code being debugged runs under the project's own virtualenv, resolved by
-- `venv_python` below, so no project ever needs debugpy installed in it -- this is how
-- VS Code drives arbitrary venvs too.

local M = {}

local dap = require("dap")

local is_windows = vim.fn.has("win32") == 1
local venv_dirs = { ".venv", "venv", "env", ".env" }

-- Everything here searches *upward*. `hacky/change-cwd.lua` chdirs into whatever nvim was
-- opened with, so having the cwd be a subdirectory of the project is the normal case, and
-- the venv, the .git dir and .vscode/launch.json all commonly sit above it.
local function find_upward(names, path, type)
	return vim.fs.find(names, {
		upward = true,
		type = type,
		path = path or vim.fn.getcwd(),
	})[1]
end

local function python_in(venv)
	local python = is_windows and vim.fs.joinpath(venv, "Scripts", "python.exe")
		or vim.fs.joinpath(venv, "bin", "python")
	if vim.fn.executable(python) == 1 then
		return python
	end
	return nil
end

--- Root of the project `path` belongs to: the git root, else a directory holding a venv,
--- else `path` itself.
---@param path string|nil
---@return string
function M.project_root(path)
	path = path or vim.fn.getcwd()
	local root = vim.fs.root(path, ".git")
	if root then
		return root
	end
	local venv = find_upward(venv_dirs, path, "directory")
	if venv then
		return vim.fs.dirname(venv)
	end
	return path
end

--- The interpreter that debugged code and tests run under. Always returns a string, because
--- neotest-python errors out on a nil.
---@param path string|nil
---@return string
function M.venv_python(path)
	if vim.env.VIRTUAL_ENV then
		local python = python_in(vim.env.VIRTUAL_ENV)
		if python then
			return python
		end
	end
	local venv = find_upward(venv_dirs, path, "directory")
	if venv then
		local python = python_in(venv)
		if python then
			return python
		end
	end
	local system = vim.fn.exepath("python3")
	return system ~= "" and system or "python3"
end

if vim.env.DEBUGPY_PYTHON and vim.env.DEBUGPY_PYTHON ~= "" then
	local dap_python = require("dap-python")
	-- Registers the `python` adapter plus the default `file`, `file:args`, `file:doctest`
	-- and `attach` configurations.
	dap_python.setup(vim.env.DEBUGPY_PYTHON)
	dap_python.resolve_python = M.venv_python
	dap_python.test_runner = "pytest"

	-- The one case the defaults miss: `python -m some.module`, which is how packages without
	-- a console script are started.
	table.insert(dap.configurations.python, {
		type = "python",
		request = "launch",
		name = "module:args",
		module = function()
			return vim.fn.input("Module: ")
		end,
		args = function()
			return require("dap.utils").splitstr(vim.fn.input("Arguments: "))
		end,
		cwd = function()
			return M.project_root()
		end,
		console = "integratedTerminal",
		justMyCode = false,
	})
else
	vim.notify(
		"DEBUGPY_PYTHON is unset -- rebuild the nvim flake to enable python debugging",
		vim.log.levels.WARN,
		{ title = "DAP" }
	)
end

-- Rust, C and C++ debug through lldb-dap. macOS keeps it inside the Xcode command line
-- tools rather than on PATH, hence the `xcrun -f` fallback; elsewhere it comes from nixpkgs'
-- lldb in the flake's `dependencies`. launch.json entries select it with `"type": "lldb-dap"`.
local function lldb_dap_path()
	if vim.fn.executable("lldb-dap") == 1 then
		return vim.fn.exepath("lldb-dap")
	end
	-- Guarded: system() with a list errors out when the command does not exist at all.
	if vim.fn.executable("xcrun") == 1 then
		local path = vim.trim(vim.fn.system({ "xcrun", "-f", "lldb-dap" }))
		if vim.v.shell_error == 0 and vim.fn.executable(path) == 1 then
			return path
		end
	end
	return nil
end

local lldb_dap = lldb_dap_path()
if lldb_dap then
	dap.adapters["lldb-dap"] = {
		type = "executable",
		command = lldb_dap,
	}
else
	vim.notify(
		"lldb-dap not found -- native (Rust/C/C++) debugging is unavailable",
		vim.log.levels.WARN,
		{ title = "DAP" }
	)
end

-- Replace ${workspaceFolder} with the *project* root rather than the cwd. nvim-dap expands
-- it to vim.fn.getcwd(), which is wrong whenever nvim was opened on a subdirectory -- e.g.
-- opening a `tools/` package whose launch.json and git root both live above it. Mutates in
-- place so that metatables (launch.json `inputs` set a __call one) survive. Only the two
-- workspace variables are touched; ${file} and friends are left for nvim-dap to expand.
local function substitute_root(value, root, basename)
	if type(value) == "string" then
		return (value:gsub("%${workspaceFolder}", root):gsub("%${workspaceFolderBasename}", basename))
	end
	if type(value) == "table" then
		for k, v in pairs(value) do
			value[k] = substitute_root(v, root, basename)
		end
	end
	return value
end

-- Overrides nvim-dap's built-in provider of the same name, which reads
-- `vim.fn.getcwd() .. "/.vscode/launch.json"`. Being a provider, it is re-read on every
-- launch, so editing launch.json takes effect immediately -- no reload command needed.
dap.providers.configs["dap.launch.json"] = function()
	local root = M.project_root()
	local path = vim.fs.joinpath(root, ".vscode", "launch.json")
	if vim.fn.filereadable(path) == 0 then
		return {}
	end
	local ok, configs = pcall(require("dap.ext.vscode").getconfigs, path)
	if not ok then
		vim.notify("Can't read " .. path .. ":\n" .. tostring(configs), vim.log.levels.WARN, { title = "DAP" })
		return {}
	end
	-- `%` is the escape character in a gsub replacement, so escape it in the roots.
	local escaped_root = root:gsub("%%", "%%%%")
	local escaped_basename = vim.fs.basename(root):gsub("%%", "%%%%")
	for _, config in ipairs(configs) do
		substitute_root(config, escaped_root, escaped_basename)
		config.cwd = config.cwd or root
	end
	return configs
end

-- https://github.com/rcarriga/nvim-dap-ui
require("dapui").setup({})
require("nvim-dap-virtual-text").setup({})

dap.listeners.after.event_initialized["dapui"] = function()
	require("dapui").open()
end
dap.listeners.before.event_terminated["dapui"] = function()
	require("dapui").close()
end
dap.listeners.before.event_exited["dapui"] = function()
	require("dapui").close()
end

vim.keymap.set("n", "<leader>db", function()
	dap.toggle_breakpoint()
end, { noremap = true, silent = true, desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { noremap = true, silent = true, desc = "Set conditional breakpoint" })
vim.keymap.set("n", "<leader>dc", function()
	dap.continue()
end, { noremap = true, silent = true, desc = "Continue / start debugging" })
vim.keymap.set("n", "<leader>di", function()
	dap.step_into()
end, { noremap = true, silent = true, desc = "Step into" })
vim.keymap.set("n", "<leader>do", function()
	dap.step_over()
end, { noremap = true, silent = true, desc = "Step over" })
vim.keymap.set("n", "<leader>dO", function()
	dap.step_out()
end, { noremap = true, silent = true, desc = "Step out" })
vim.keymap.set("n", "<leader>dr", function()
	dap.repl.toggle()
end, { noremap = true, silent = true, desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>dt", function()
	dap.terminate()
end, { noremap = true, silent = true, desc = "Terminate session" })
vim.keymap.set("n", "<leader>dl", function()
	dap.run_last()
end, { noremap = true, silent = true, desc = "Re-run last configuration" })
vim.keymap.set({ "n", "v" }, "<leader>de", function()
	require("dapui").eval()
end, { noremap = true, silent = true, desc = "Evaluate expression" })
vim.keymap.set("n", "<leader>du", function()
	require("dapui").toggle()
end, { noremap = true, silent = true, desc = "Toggle debugger UI" })

return M
