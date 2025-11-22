--[[

=====================================================================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||                    ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 15

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
--
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Smart quit
local function smartQuit()
	vim.ui.select({ "Cancel", "All", "Current" }, { prompt = "Close which?" }, function(choice)
		if choice == "All" then
			local bUnsaved = false
			local sName = ""
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.bo[buf].modified then
					bUnsaved = true
					sName = vim.api.nvim_buf_get_name(buf)
					local index = string.match(sName, ".*/()")
					if index ~= nil then
						sName = string.sub(sName, index)
					end
				end
			end
			if bUnsaved then
				vim.ui.select({ "Cancel", "Save and exit", "Exit without saving" }, {
					prompt = '"' .. sName .. '" has unsaved changes. Choose what to do...',
				}, function(choice1)
					if choice1 == "Save and exit" then
						vim.cmd("wqall")
						return
					elseif choice1 == "Exit without saving" then
						vim.cmd("qa!")
						return
					elseif choice1 == "Cancel" then
						return
					end
				end)
			else
				vim.cmd("qa")
				return
			end
		elseif choice == "Current" then
			if vim.bo[vim.api.nvim_get_current_buf()].modified then
				vim.ui.select({ "Cancel", "Save and exit", "Exit without saving" }, {
					prompt = "Unsaved changes detected. What do you want to do?",
				}, function(choice2)
					if choice2 == "Save and exit" then
						vim.cmd("wq")
						return
					elseif choice2 == "Exit without saving" then
						vim.cmd("q!")
						return
					elseif choice2 == "Cancel" then
						return
					end
				end)
			else
				vim.cmd("q")
				return
			end
		elseif choice == "Cancel" then
			return
		end
	end)
end

local smoothDoubleCharChart = {
	['"'] = '"',
	["'"] = "'",
	["("] = ")",
	["["] = "]",
	["<"] = ">",
	["{"] = "}",
	[")"] = ")",
	["]"] = "]",
	[">"] = ">",
	["}"] = "}",
}

local doubleQuotesEnabled = true

local function smoothDoubleQuotes(char)
	local curWin = vim.api.nvim_get_current_win()
	local pos = vim.fn.getcursorcharpos(curWin)
	local curLine = vim.api.nvim_get_current_line()
	local curChar = string.sub(curLine, pos[3], pos[3])
	if not doubleQuotesEnabled then
		local newLine = string.sub(curLine, 1, pos[3] - 1) .. char .. string.sub(curLine, pos[3])
		vim.api.nvim_set_current_line(newLine)
		vim.api.nvim_win_set_cursor(curWin, { pos[2], pos[3] })
		return
	end
	if curChar == char then
		vim.api.nvim_win_set_cursor(curWin, { pos[2], pos[3] })
		return
	elseif not (char == ")" or char == "]" or char == ">" or char == "}") then
		local newLine = string.sub(curLine, 1, pos[3] - 1)
			.. char
			.. smoothDoubleCharChart[char]
			.. string.sub(curLine, pos[3])
		vim.api.nvim_set_current_line(newLine)
		vim.api.nvim_win_set_cursor(curWin, { pos[2], pos[3] })
		return
	else
		local newLine = string.sub(curLine, 1, pos[3] - 1) .. char .. string.sub(curLine, pos[3])
		vim.api.nvim_set_current_line(newLine)
		vim.api.nvim_win_set_cursor(curWin, { pos[2], pos[3] })
	end
end

local function moveLinesUp()
	local vEnd = vim.api.nvim_win_get_cursor(0)[1]
	local vStart = vim.fn.getpos("v")[2]
	local moveAmount = math.abs(vEnd - vStart) + 1
	local lineToMove = math.min(vEnd, vStart) - 1

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	vim.api.nvim_win_set_cursor(0, { lineToMove, 0 })
	local cmdLine = ":m+" .. moveAmount
	vim.cmd(cmdLine)
	vim.api.nvim_win_set_cursor(0, { math.max(vEnd, vStart) - 1, 0 })
	local fkeys = "$v" .. moveAmount - 1 .. "k0"
	vim.api.nvim_feedkeys(fkeys, "n", true)
end

local function moveLinesDown()
	local vEnd = vim.api.nvim_win_get_cursor(0)[1]
	local vStart = vim.fn.getpos("v")[2]
	local moveAmount = math.abs(vEnd - vStart) + 2
	local lineToMove = math.max(vEnd, vStart) + 1

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	vim.api.nvim_win_set_cursor(0, { lineToMove, 0 })
	local cmdLine = ":m-" .. moveAmount
	vim.cmd(cmdLine)
	vim.api.nvim_win_set_cursor(0, { math.max(vEnd, vStart) + 1, 0 })
	local fkeys = "$v" .. moveAmount - 2 .. "k0"
	vim.api.nvim_feedkeys(fkeys, "n", true)
end

vim.api.nvim_create_autocmd("RecordingEnter", {
	callback = function()
		vim.print("Macro recording started...")
	end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
	callback = function()
		vim.print("Macro recording finished.")
	end,
})

local curTheme
local startTheme
local favThemes = {}

local function loadTheme()
	for line in io.lines(vim.fn.stdpath("config") .. "/vars") do
		if string.find(line, "theme=") then
			local sTheme = string.sub(line, 7)
			vim.cmd("colorscheme " .. sTheme)
			curTheme = sTheme
			startTheme = sTheme
			vim.print("Theme '" .. sTheme .. "' has been loaded.")
			return
		end
	end
	vim.print("Theme not found from file: " .. vim.fn.stdpath("config") .. "/vars")
end

local function setTheme(newTheme)
	vim.cmd("colorscheme " .. newTheme)
	curTheme = newTheme
	vim.print("Theme set to: " .. newTheme)
	local fileOut = ""
	local bThemeFound = false
	for line in io.lines(vim.fn.stdpath("config") .. "/vars") do
		if string.find(line, "theme") then
			fileOut = fileOut .. "theme=" .. newTheme .. "\n"
			bThemeFound = true
		else
			fileOut = fileOut .. line .. "\n"
		end
	end
	if not bThemeFound then
		fileOut = fileOut .. "theme=" .. newTheme .. "\n"
	end
	io.output(vim.fn.stdpath("config") .. "/vars")
	io.write(fileOut)
	io.close()
end

local function nextTheme()
	local themeList = vim.fn.getcompletion("", "color")
	if curTheme == nil then
		setTheme(themeList[1])
		return
	end
	for i, v in ipairs(themeList) do
		if i == #themeList then
			setTheme(themeList[1])
			return
		end
		if curTheme == v then
			setTheme(themeList[i + 1])
			return
		end
	end
end

local function prevTheme()
	local themeList = vim.fn.getcompletion("", "color")
	if curTheme == nil then
		setTheme(themeList[#themeList])
		return
	end
	for i, v in ipairs(themeList) do
		if curTheme == v then
			if i ~= 1 then
				setTheme(themeList[i - 1])
				return
			else
				setTheme(themeList[#themeList])
				return
			end
		end
	end
end

local function randTheme()
	local themeList = vim.fn.getcompletion("", "color")
	setTheme(themeList[math.random(#themeList)])
end

local function resetTheme()
	setTheme(startTheme)
end

local function populateFavThemes()
	if #favThemes ~= nil then
		local count = #favThemes
		for i = 0, count do
			favThemes[i] = nil
		end
	end
	for line in io.lines(vim.fn.stdpath("config") .. "/vars") do
		if string.find(line, "favTheme=") then
			table.insert(favThemes, string.sub(line, 10))
		end
	end
end

local function saveFavThemesToFile()
	local output = ""
	if #favThemes == nil then
		vim.print("There are no favorite themes.")
		return
	end
	for line in io.lines(vim.fn.stdpath("config") .. "/vars") do
		if not string.find(line, "favTheme=") then
			output = output .. line .. "\n"
		end
	end
	for _, value in pairs(favThemes) do
		output = output .. "favTheme=" .. value .. "\n"
	end
	local file = io.output(vim.fn.stdpath("config") .. "/vars")
	if file == nil then
		vim.print("Var file not found")
		return
	end
	io.write(output)
	io.close(file)
end

local function toggleThemeFavorite()
	for index, value in ipairs(favThemes) do
		if value == curTheme then
			table.remove(favThemes, index)
			saveFavThemesToFile()
			vim.print("Removed " .. curTheme .. " from favorites.")
			return
		end
	end

	table.insert(favThemes, curTheme)
	saveFavThemesToFile()
	vim.print("Added " .. curTheme .. " to favorites.")
end

local function randFavTheme()
	setTheme(favThemes[math.random(#favThemes)])
end

local function openFavThemeMenu()
	vim.ui.select(favThemes, { prompt = "Favorite Themes" }, function(choice)
		vim.print(choice)
		if choice == nil then
			return
		else
			setTheme(choice)
		end
	end)
end

-- TODO: need to set to use either tab or spaces based on which the file uses
local function indentCurrentSelection()
	if vim.fn.mode() == "v" then
		local vEnd = vim.api.nvim_win_get_cursor(0)[1]
		local vStart = vim.fn.getpos("v")[2]
		local lines = vim.api.nvim_buf_get_lines(0, math.min(vStart, vEnd) - 1, math.max(vStart, vEnd), true)
		for i, l in ipairs(lines) do
			lines[i] = "\t" .. l
		end
		vim.api.nvim_buf_set_lines(0, math.min(vStart, vEnd) - 1, math.max(vStart, vEnd), true, lines)
	else
		vim.api.nvim_set_current_line("\t" .. vim.api.nvim_get_current_line())
	end
end

local function deindentCurrentSelection()
	if vim.fn.mode() == "v" then
		local vEnd = vim.api.nvim_win_get_cursor(0)[1]
		local vStart = vim.fn.getpos("v")[2]
		local lines = vim.api.nvim_buf_get_lines(0, math.min(vStart, vEnd) - 1, math.max(vStart, vEnd), true)
		for i, l in ipairs(lines) do
			if string.sub(l, 1, 1) == "\t" then
				lines[i] = string.sub(l, 2)
			end
		end
		vim.api.nvim_buf_set_lines(0, math.min(vStart, vEnd) - 1, math.max(vStart, vEnd), true, lines)
	else
		local curLine = vim.api.nvim_get_current_line()
		if string.sub(curLine, 1, 1) == "\t" then
			vim.api.nvim_set_current_line(string.sub(curLine, 2))
		end
	end
end

--riekey      \/keybinds\/      /\functions/\

vim.keymap.set({ "n", "i", "t" }, "<F6>", '<CMD>lua require("FTerm").toggle()<CR>', { noremap = true })
vim.keymap.set({ "n", "i", "v" }, "<F7>", "<cmd>CccPick<CR>", { noremap = true })

vim.keymap.set("n", "<C-b>", "<cmd>DapToggleBreakpoint<CR>", { noremap = true })

vim.keymap.set("n", "<C-t>", openFavThemeMenu, { noremap = true })
vim.keymap.set("n", "<C-0>", randFavTheme, { noremap = true })

vim.keymap.set({ "n", "v" }, "<leader>il", indentCurrentSelection, { noremap = true, desc = "[I]ndent [L]ine(s)." })
vim.keymap.set(
	{ "n", "v" },
	"<leader>dl",
	deindentCurrentSelection,
	{ noremap = true, desc = "[D]e-Indent [L]ine(s)." }
)

vim.keymap.set("n", "<C-9>", toggleThemeFavorite, { noremap = true })

vim.keymap.set("n", "<C-]>", nextTheme, { noremap = true })
vim.keymap.set("n", "<C-[>", prevTheme, { noremap = true })
vim.keymap.set("n", "<C-\\>", randTheme, { noremap = true })
-- vim.keymap.set("n", "<C-0>", resetTheme, { noremap = true })

vim.keymap.set("n", "<F9>", "<cmd>:UndotreeToggle<CR>", { noremap = true })
vim.keymap.set({ "n", "i", "v" }, "<F11>", "<cmd>:lua require('mini.map').toggle()<CR>", { noremap = true })

vim.keymap.set(
	{ "n", "v", "i" },
	"<F4>",
	'<cmd>:lua require("personalPlugin").toggleNotesWindow()<CR>',
	{ noremap = true }
)
vim.keymap.set("n", "<leader>z", "zfi{", { noremap = true })

vim.keymap.set({ "n", "v" }, "<C-j>", '<cmd>call smoothie#do("<C-D>zz")<CR>', { desc = "Center line when moving down" })
vim.keymap.set({ "n", "v" }, "<C-k>", '<cmd>call smoothie#do("<C-U>zz")<CR>', { desc = "Center line when moving up" })

vim.keymap.set("n", "<leader>st", function()
	vim.cmd("set shiftwidth=4")
	vim.cmd("set tabstop=4")
end, { desc = "Set Tab Settings" })

vim.keymap.set("i", "<A-l>", "<right>", { noremap = true })
vim.keymap.set("i", "<A-h>", "<left>", { noremap = true })
vim.keymap.set("i", "<A-k>", "<up>", { noremap = true })
vim.keymap.set("i", "<A-j>", "<down>", { noremap = true })

vim.keymap.set("i", "<S-Backspace>", function()
	local curWin = vim.api.nvim_get_current_win()
	local pos = vim.fn.getcursorcharpos(curWin)
	local curLine = vim.api.nvim_get_current_line()
	if pos[3] ~= string.len(curLine) + 1 then
		local key = vim.api.nvim_replace_termcodes("<Delete>", true, true, true)
		vim.api.nvim_feedkeys(key, "i", true)
	end
end)

vim.keymap.set({ "n", "i" }, "<S-A-j>", "<cmd>:m+<CR>", { desc = "Move line/selection down" })
vim.keymap.set({ "n", "i" }, "<S-A-k>", "<cmd>:m-2<CR>", { desc = "Move line/selection up" })
vim.keymap.set("v", "<S-A-j>", moveLinesDown)
vim.keymap.set("v", "<S-A-k>", moveLinesUp)

vim.keymap.set("n", "<F2>", "<cmd>:edit ~/.config/nvim/init.lua<CR>", { desc = "Edit init.lua file" })
vim.keymap.set({ "n", "i" }, "<F5>", "<cmd>:w<CR>", { desc = "Save current file" })
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>:w<CR>", { desc = "Save current file" })
vim.keymap.set("v", "<leader>p", '"_dP', { desc = "[P]aste without overwriting buffer" })
vim.keymap.set({ "n", "i" }, "<F12>", smartQuit, { desc = "Smart Quit" })
-- vim.keymap.set("n", "<C-f>", "<cmd>:lua require('harpoon.ui').toggle_quick_menu()<CR>")
-- vim.keymap.set("n", "<F7>", "<cmd>:lua require('harpoon.mark').toggle_file()<CR>")
vim.keymap.set("n", "<C-x>", "<cmd>BufferClose<CR>")
--vim.keymap.set("n", "<F6>", "<cmd>BufferPick<CR>")

vim.keymap.set("n", "<C-S-n>", "<cmd>BufferNext<CR>")
vim.keymap.set("n", "<C-S-p>", "<cmd>BufferPrevious<CR>")

vim.keymap.set({ "n", "i" }, "<A-d>", "<Esc><cmd>:wincmd l<CR>")
vim.keymap.set({ "n", "i" }, "<A-a>", "<Esc><cmd>:wincmd h<CR>")
vim.keymap.set({ "n", "i" }, "<A-w>", "<Esc><cmd>:wincmd k<CR>")
vim.keymap.set({ "n", "i" }, "<A-s>", "<Esc><cmd>:wincmd j<CR>")

vim.keymap.set({ "n", "i" }, "<C-q>", function()
	doubleQuotesEnabled = not doubleQuotesEnabled
	vim.print("Smooth Quotes " .. tostring(doubleQuotesEnabled))
end)

vim.keymap.set("i", '"', function()
	smoothDoubleQuotes('"')
end)
vim.keymap.set("i", "<A-S-'>", '"')

vim.keymap.set("i", "'", function()
	smoothDoubleQuotes("'")
end)
vim.keymap.set("i", "<A-'>", "'")

vim.keymap.set("i", "(", function()
	smoothDoubleQuotes("(")
end)
vim.keymap.set("i", "<A-S-9>", "(")

vim.keymap.set("i", ")", function()
	smoothDoubleQuotes(")")
end)
vim.keymap.set("i", "<A-S-0>", ")")

vim.keymap.set("i", "[", function()
	smoothDoubleQuotes("[")
end)
vim.keymap.set("i", "<A-[>", "[")

vim.keymap.set("i", "]", function()
	smoothDoubleQuotes("]")
end)
vim.keymap.set("i", "<A-]>", "]")

vim.keymap.set("i", "{", function()
	smoothDoubleQuotes("{")
end)
vim.keymap.set("i", "<A-S-[>", "{")

vim.keymap.set("i", "}", function()
	smoothDoubleQuotes("}")
end)
vim.keymap.set("i", "<A-S-]>", "}")

vim.keymap.set("i", "<", function()
	smoothDoubleQuotes("<")
end)
vim.keymap.set("i", "<A-S-,>", "<")

vim.keymap.set("i", ">", function()
	smoothDoubleQuotes(">")
end)
vim.keymap.set("i", "<A-S-.>", ">")

vim.keymap.set({ "n", "i" }, "<F3>", '<cmd>:lua require("Basher").toggleMainWin()<CR>')
vim.keymap.set({ "n", "i" }, "<C-1>", '<cmd>:lua require("Basher").runScript(1)<CR>')
vim.keymap.set({ "n", "i" }, "<C-2>", '<cmd>:lua require("Basher").runScript(2)<CR>')
vim.keymap.set({ "n", "i" }, "<C-3>", '<cmd>:lua require("Basher").runScript(3)<CR>')
vim.keymap.set({ "n", "i" }, "<C-4>", '<cmd>:lua require("Basher").runScript(4)<CR>')

--for some reason puts a capital "A" and tries to execute it
--found this is because colorscheme menu does this, TODO: fix this for other options
--haven't had a use for this except changing colorscheme so won't change this until I need to
vim.keymap.set("n", "<C-F5>", "<cmd>@:<CR><Backspace><Esc>A")

vim.keymap.set("n", "<F8>", '<cmd>:lua require("dapui").toggle({ reset = true })<CR>')
-- vim.keymap.set("n", "<F8>", '<cmd>:lua require("dap").toggle_breakpoint()<CR>')
vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "[D]ap Toggle [B]reakpoint" })
vim.keymap.set("n", "<leader>di", "<cmd>DapStepInto<CR>", { desc = "[D]ap Step [I]nto" })
vim.keymap.set("n", "<leader>do", "<cmd>DapStepOver<CR>", { desc = "[D]ap Step [O]ver" })
vim.keymap.set("n", "<leader>du", "<cmd>DapStepOut<CR>", { desc = "[D]ap Step O[u]t" })
vim.keymap.set("n", "<leader>dc", "<cmd>DapContinue<CR>", { desc = "[D]ap [C]ontinue" })
vim.keymap.set("n", "<leader>dt", "<cmd>DapTerminate<CR>", { desc = "[D]ap [T]erminate" })

vim.keymap.set("n", "<F10>", "<cmd>:Neotree float toggle<CR>")

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- godot editing stuff
-- TODO: doesn't seem to work
if vim.uv.fs_stat(vim.fn.getcwd() .. "project.godot") and not vim.uv.fs_stat("/tmp/gdnv.pipe") then
	vim.print("Starting Godot NeoVim Pipe Server")
	vim.fn.serverstart("/tmp/gdnv.pipe")
end

-- [[ Install `lazy.nvim` plugin manager ]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more inf
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
require("lazy").setup({

	{ -- You can easily change to a different colorscheme.
		-- Change the name of the colorscheme plugin below, and then
		-- change the command in the config to whatever the name of that colorscheme is.
		--
		-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
		"folke/tokyonight.nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		init = function()
			-- Load the colorscheme here.
			-- Like many other themes, this one has different styles, and you could load
			-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
			-- vim.cmd.colorscheme("tokyonight")
			populateFavThemes()
			-- loadTheme()

			-- You can configure highlights by doing something like:
			-- vim.cmd.hi("Comment gui=none")
		end,
	},
	-- init.lua. If you want these files, they are in the repository, so you can just download them and
	-- place them in the correct locations.

	-- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
	--
	--  Here are some example plugins that I've included in the Kickstart repository.
	--  Uncomment any of the lines below to enable them (you will need to restart nvim).
	--
	-- require("kickstart.plugins.debug"),
	-- require("kickstart.plugins.indent_line"),
	-- require("kickstart.plugins.lint"),
	-- require("kickstart.plugins.autopairs"),
	-- require("kickstart.plugins.neo-tree"),
	-- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

	{ import = "custom.plugins" },
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- Supermaven highlight color isn't set correctly unless this is here
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		randFavTheme()
	end,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
