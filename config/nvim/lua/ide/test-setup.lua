local python = require("neotest-python")({
	-- neotest-python only looks one level below its root for a venv, so a project whose venv
	-- sits above the cwd falls back to whatever `python3` is on PATH -- which has none of the
	-- project's dependencies. Resolve it ourselves by searching upward instead.
	python = require("ide.dap-setup").venv_python,
	dap = { justMyCode = false },
})

-- neotest-python declares a root only for pyproject.toml/setup.cfg/mypy.ini/pytest.ini/
-- setup.py. A plain requirements.txt project gets no root at all, and neotest then skips it
-- for every file already covered by another adapter's root (see AdapterGroup:
-- adapters_matching_open_bufs) -- so its tests are never discovered. Widen the patterns and
-- fall back to the repo root.
local match_python_root = require("neotest.lib").files.match_root_pattern(
	"pyproject.toml",
	"setup.cfg",
	"mypy.ini",
	"pytest.ini",
	"tox.ini",
	"setup.py",
	"Pipfile",
	"requirements.txt"
)
python.root = function(dir)
	return match_python_root(dir) or vim.fs.root(dir, ".git")
end

-- With the repo root as a possible root, keep discovery out of the directories that are
-- never worth scanning. The stock filter only excludes a literal "venv".
python.filter_dir = function(name)
	return name ~= "venv" and name ~= ".venv" and name ~= ".git" and name ~= "__pycache__" and name ~= "node_modules"
end

require("neotest").setup({
	consumers = {
		overseer = require("neotest.consumers.overseer"),
	},
	adapters = { python },
})

vim.keymap.set("n", "<leader>tr", function()
	require("neotest").run.run()
end, { noremap = true, silent = true, desc = "Run current nearest test" })
vim.keymap.set("n", "<leader>td", function()
	require("neotest").run.run({ strategy = "dap" })
end, { noremap = true, silent = true, desc = "Debug current nearest test" })
vim.keymap.set("n", "<leader>tD", function()
	require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
end, { noremap = true, silent = true, desc = "Debug all tests in current file" })
vim.keymap.set("n", "<leader>ts", function()
	require("neotest").summary.toggle()
end, { noremap = true, silent = true, desc = "Toggle summary" })
vim.keymap.set("n", "<leader>tl", function()
	require("neotest").run.run_last()
end, { noremap = true, silent = true, desc = "Run latest" })
vim.keymap.set("n", "<leader>to", function()
	require("neotest").output_panel.open()
end, { noremap = true, silent = true, desc = "Run latest" })
