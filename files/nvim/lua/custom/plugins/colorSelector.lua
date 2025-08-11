return {
	{
		"uga-rosa/ccc.nvim",
		config = function()
			vim.opt.termguicolors = true
			require("ccc").setup({
				highlighter = {
					auto_enable = true,
					lsp = true,
				},
			})
		end,
	},
}
