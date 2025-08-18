return {
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
		},
		config = function()
			require("dapui").setup()

			local dap = require("dap")
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			}
			dap.configurations.cpp = {
				-- {
				-- 	name = "Launch file",
				-- 	type = "gdb",
				-- 	request = "launch",
				-- 	program = function()
				-- 		return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				-- 	end,
				-- 	cwd = "${workspaceFolder}",
				-- 	stopAtEntry = true,
				-- 	setupCommands = {
				-- 		{
				-- 			text = "-enable-pretty-printing",
				-- 			description = "enable pretty printing",
				-- 			ignoreFailures = false,
				-- 		},
				-- 	},
				-- },
				{
					name = "Launch",
					type = "gdb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtBeginningOfMainSubprogram = false,
				},
				-- {
				-- 	name = "Attach to gdbserver :1234",
				-- 	type = "cppdbg",
				-- 	request = "launch",
				-- 	MIMode = "gdb",
				-- 	miDebuggerServerAddress = "localhost:1234",
				-- 	miDebuggerPath = "/usr/bin/gdb",
				-- 	cwd = "${workspaceFolder}",
				-- 	program = function()
				-- 		return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				-- 	end,
				-- 	setupCommands = {
				-- 		{
				-- 			text = "-enable-pretty-printing",
				-- 			description = "enable pretty printing",
				-- 			ignoreFailures = false,
				-- 		},
				-- 	},
				-- },
			}
		end,
	},
}
