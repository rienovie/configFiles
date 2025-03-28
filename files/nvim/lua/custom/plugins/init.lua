-- I'll put plugins that have little configuration in here

return {
	{ "amber-lang/amber-vim" },
	{ "tpope/vim-sleuth" },
	{ "numToStr/Comment.nvim", opts = {} },
	{ "psliwka/vim-smoothie" },
	{ "tinted-theming/base16-vim" },
	{ "xiyaowong/transparent.nvim", opts = {} },
	{ "nvim-treesitter/nvim-treesitter-context", opts = {} },
	{ "ThePrimeagen/harpoon", opts = {} },
	{ "mfussenegger/nvim-dap" },
	{ "numToStr/FTerm.nvim" },
	{ "mfussenegger/nvim-jdtls" },

	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
			"ibhagwan/fzf-lua", -- optional
			"echasnovski/mini.pick", -- optional
		},
		config = true,
	},
	-- Local version to use when editing
	-- { "Basher", dir = "~/projects/Basher", opts = { funOnStart = false, pathMaxDirs = 1 } },
	-- Version to test from git
	{ "rienovie/Basher", event = "VeryLazy", opts = { silencePrints = false } },

	{ "personalPlugin", dir = (vim.fn.stdpath("config") .. "/personalPlugin") },
}
