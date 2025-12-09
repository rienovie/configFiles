-- needed for running from anywhere
-- TODO: look into adding to default path
package.path = package.path .. ";/home/vince/Scripts/lua/?.lua"

local common = require("common")

common.printTable(common.scanDir("/home/vince/Scripts/lua", true))
