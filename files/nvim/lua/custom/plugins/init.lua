-- I'll put plugins that have little configuration in here

return {
	{ "tpope/vim-sleuth" },
	{ "numToStr/Comment.nvim", opts = {} },
	{ "psliwka/vim-smoothie" },
	{ "tinted-theming/base16-vim" },
	{ "xiyaowong/transparent.nvim", opts = {} },
	{ "nvim-treesitter/nvim-treesitter-context", opts = {} },
	{ "ThePrimeagen/harpoon", opts = {} },
	{ "mfussenegger/nvim-dap" },

	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	-- Local version to use when editing
	-- { "Basher", dir = "~/projects/Basher", opts = { funOnStart = false, pathMaxDirs = 1 } },
	-- Version to test from git
	{ "rienovie/Basher", event = "VeryLazy", opts = { silencePrints = false } },

	{ "personalPlugin", dir = (vim.fn.stdpath("config") .. "/personalPlugin") },
}
