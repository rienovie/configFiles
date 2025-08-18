-- main module file
local module = require("personalPlugin.module")

---@class Config
---@field opt string Your config option
local config = {}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
M.setup = function(args)
	M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.openNotesFile = function()
	return module.open_notes_window()
end

M.closeNotesWindow = function()
	return module.close_notes_window()
end

M.toggleNotesWindow = function()
	return module.toggle_notes_window()
end

return M
