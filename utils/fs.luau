local Process = require("@lune/process")

local Utils = {}

-- Utility function to create a temporary directory quickly
function Utils.MakeTemp(): (boolean, string)
	local filePathChild = Process.spawn("mktemp")

	return filePathChild.ok, (filePathChild.ok and filePathChild.stdout:gsub("%s", "")) or ""
end

return Utils