return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "base16",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {
						statusline = {},
						winbar = {
							"dap-repl",
							"dapui_watches",
							"dapui_stacks",
							"dapui_breakpoints",
							"dapui_scopes",
							"dapui_console",
						},
					},
					ignore_focus = {},
					always_divide_middle = true,
					globalstatus = false,
					refresh = {
						statusline = 1000,
						tabline = 1000,
						winbar = 1000,
					},
				},
				sections = {
					-- lualine_a = { "mode" },
					-- lualine_b = { "branch", "diff" },
					-- lualine_c = { "filename" },
					-- lualine_x = { "encoding", "fileformat", "filetype" },
					-- lualine_y = { "diagnostics" },
					-- lualine_z = { "location" },
				},
				inactive_sections = {
					-- lualine_a = {},
					-- lualine_b = {},
					-- lualine_c = { "filename" },
					-- lualine_x = { "location" },
					-- lualine_y = {},
					-- lualine_z = {},
				},
				tabline = {},
				winbar = {
					lualine_a = { "mode", "filename" },
					lualine_b = { "filetype", "diagnostics" },
					lualine_c = {},
					lualine_x = {},
					lualine_y = { "diff" },
					lualine_z = { "progress", "location" },
				},
				inactive_winbar = {},
				extensions = { "nvim-dap-ui", "nvim-tree", "trouble", "neo-tree", "lazy", "mason" },
			})
			vim.opt.laststatus = 0
		end,
	},
}
