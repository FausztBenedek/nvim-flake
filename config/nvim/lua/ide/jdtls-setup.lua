local M = {}

local function copy_jdtls_config_to_writable_location()
	local os_name = vim.uv.os_uname().sysname
	local new_config_path = vim.fn.stdpath("data") .. "/jdtls/config_" .. (os_name == "Linux" and "linux" or "mac")
	local marker_file = new_config_path .. "/.nvim-jdtls-source"

	-- Re-copy whenever the nix store path changes (new jdtls version installed)
	local stored_source = ""
	local f = io.open(marker_file, "r")
	if f then
		stored_source = f:read("*l") or ""
		f:close()
	end

	if stored_source ~= vim.env.JAVA_JDTLS then
		vim.fn.system({ "rm", "-rf", new_config_path })
		vim.fn.mkdir(new_config_path, "p")

		local original_config_path = vim.env.JAVA_JDTLS
			.. "/share/java/jdtls/config_"
			.. (os_name == "Windows_NT" and "win" or os_name == "Linux" and "linux" or "mac")
			.. "/."

		vim.fn.system({ "cp", "-r", original_config_path, new_config_path })

		local mf = io.open(marker_file, "w")
		if mf then
			mf:write(vim.env.JAVA_JDTLS)
			mf:close()
		end
	end
	return new_config_path
end

function M:setup()
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	local sep = package.config:sub(1, 1)
	local configuration = copy_jdtls_config_to_writable_location()
	local lombok_path = vim.env.LOMBOK_JAR -- Set by nix

	local workspace_dir = vim.fn.stdpath("data") .. sep .. "jdtls-workspace" .. sep .. project_name
	local launcher = vim.fn.glob(vim.env.JAVA_JDTLS .. "/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar")

	local debug_jars = vim.fn.glob(vim.env.JAVA_DEBUG_DIR .. "/server/*.jar", false, true)
	local test_jars = vim.fn.glob(vim.env.JAVA_TEST_DIR .. "/server/*.jar", false, true)
	local bundles = vim.list_extend(debug_jars, test_jars)

	local config = {
		-- The command that starts the language server
		-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
		cmd = {

			-- 💀
			"java", -- or '/path/to/java17_or_newer/bin/java'
			-- depends on if `java` is in your $PATH env variable and if it points to the right version.
			"-javaagent:" .. lombok_path,
			"-Xbootclasspath/a:" .. lombok_path,
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-Xmx1g",
			"--add-modules=ALL-SYSTEM",
			"--add-modules=jdk.incubator.vector",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
			"-jar",
			launcher,
			"-configuration",
			configuration,
			"-data",
			workspace_dir,
		},

		-- Here you can configure eclipse.jdt.ls specific settings
		-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
		-- for a list of options
		settings = {
			java = {},
		},
		on_attach = function(client, bufnr)
			require("jdtls").setup_dap({ hotcodereplace = "auto" })
			require("jdtls.dap").setup_dap_main_class_configs()
			require("dap.ext.vscode").load_launchjs(nil, { java = { "java" } })
			vim.keymap.set("n", "<leader>dtm", require("jdtls.dap").test_nearest_method, { buffer = bufnr, desc = "DAP: Debug nearest test method" })
			vim.keymap.set("n", "<leader>dtc", require("jdtls.dap").test_class, { buffer = bufnr, desc = "DAP: Debug test class" })
		end,
		init_options = {
			bundles = bundles,
		},
	}
	-- This starts a new client & server,
	-- or attaches to an existing client & server depending on the `root_dir`.
	require("jdtls").start_or_attach(config)
end

return M
