return {
	{
		"mbbill/undotree",
		config = function()
			vim.cmd("let g:undotree_WindowLayout=2")
			vim.cmd("let g:undotree_DiffAutoOpen=0")
			vim.cmd("let g:undotree_SplitWidth=32")
			vim.cmd("let g:undotree_SetFocusWhenToggle=1")
		end,
	},
}
