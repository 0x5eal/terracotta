--[[
    Wax - A Fast Runtime Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics
    MIT License | Copyright (c) 2023 Latte Softworks <https://latte.to>
]]

-- You set the following string to "latest" (case insensitive), or any version tag
-- on Wax's releases page (e.g. "0.1.1")
local WaxVersion = "latest"
local WaxPath = ".wax/wax-${version}.luau"

-------------------------------------------------------------------------------

local net = require("@lune/net")
local luau = require("@lune/luau")
local fs = require("@lune/fs")

local FilePath

if not fs.isFile(WaxPath) then
	if not fs.isDir(".wax") then
		fs.writeDir(".wax")
	end

	FilePath = WaxPath:gsub("${version}", WaxVersion)

	local FileLink = if string.lower(WaxVersion) == "latest"
		then "https://github.com/latte-soft/wax/releases/latest/download/wax.luau"
		else `https://github.com/latte-soft/wax/releases/download/{WaxVersion}/wax.luau`

	fs.writeFile(FilePath, net.request(FileLink).body)
end

luau.load(fs.readFile(FilePath))()
