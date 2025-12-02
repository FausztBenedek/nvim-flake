local M = {}

local function copy_jdtls_config_to_writable_location()
	local os_name = vim.loop.os_uname().sysname
	local new_config_path = vim.fn.stdpath("data") .. "/jdtls/config_" .. (os_name == "Linux" and "linux" or "mac")

	if vim.fn.isdirectory(new_config_path) == 0 then
		vim.fn.mkdir(new_config_path, "p")

		local original_config_path = vim.env.JAVA_JDTLS -- Set to the the installation in nix store
			.. "/share/java/jdtls/config_"
			.. (os_name == "Windows_NT" and "win" or os_name == "Linux" and "linux" or "mac")
			.. "/."

		vim.fn.system({
			"cp",
			"-r",
			original_config_path,
			new_config_path,
		})
	end
	return new_config_path
end

function M:setup()
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	local sep = package.config:sub(1, 1)
	local configuration = copy_jdtls_config_to_writable_location()

	local workspace_dir = vim.fn.stdpath("data") .. sep .. "jdtls-workspace" .. sep .. project_name
	local launcher = vim.fn.glob(vim.env.JAVA_JDTLS .. "/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar")
	local config = {
		-- The command that starts the language server
		-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
		cmd = {

			-- 💀
			"java", -- or '/path/to/java17_or_newer/bin/java'
			-- depends on if `java` is in your $PATH env variable and if it points to the right version.

			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-Xmx1g",
			"--add-modules=ALL-SYSTEM",
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

		-- Language server `initializationOptions`
		-- You need to extend the `bundles` with paths to jar files
		-- if you want to use additional eclipse.jdt.ls plugins.
		--
		-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
		--
		-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
		init_options = {
			bundles = {},
		},
	}
	-- This starts a new client & server,
	-- or attaches to an existing client & server depending on the `root_dir`.
	require("jdtls").start_or_attach(config)
end

return M
