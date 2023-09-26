--!strict
local Process = require("@lune/process")
local Fs = require("@lune/fs")

local FsUtils = require("../utils/fs")

local Darklua = {}
type DarkluaExtended = typeof(Darklua.Prototype) & { darkluaPath: string }

-- TODO: Implement wrappers around fs & process APIs that do not panic

-- TODO: binbows support :3
-- Utility function to look for a binary in the PATH and return its absolute path
local function ProcessWhich(binName: string): { path: string?, warnings: { string } | {} }
	local path: string = Process.env.PATH
	local binPath: string? = nil
	local warnings: { string } = {}

	-- If the PATH is set, and is a string, we loop divide the path into dirs
	if path and typeof(path) == "string" then
		for _, dir in path:split(":") do
			-- [1] => whether xpcall was okful
			-- [2] => collection of files in the dir
			local dirFiles: { any } = table.pack(xpcall(function()
				-- We try to read the dir
				return Fs.readDir(dir)
			end, function()
				-- If it fails, we push to warnings, and return an empty table
				table.insert(warnings, string.format("%s - NOT_FOUND", dir))
				return {}
			end))[2] :: { any }

			local binIdx = table.find(dirFiles, binName)

			-- Find the position of the binName in our directory, we strip the
			-- trailing slash, and set the dirPath in the upper scope.
			if binIdx then
				local dirPath: string = (function()
					if string.sub(dir, -1) == "/" then
						return dir:sub(1, -1)
					else
						return dir
					end
				end)()

				binPath = dirPath .. "/" .. dirFiles[binIdx]
			end
		end
	end

	return {
		path = binPath,
		warnings = warnings,
	}
end

function __DarkluaInit(sourceKind: "code" | "path", source: string): { res: { string }?, error: string? }
	local sourcePath: string

	if sourceKind == "code" then
		local ok, tmpFilePath = FsUtils.MakeTemp()

		if not ok then
			return {
				error = "failed to create temporary file for darklua minification",
			}
		end

		Fs.writeFile(tmpFilePath, source)

		sourcePath = tmpFilePath
	elseif sourceKind == "path" then
		sourcePath = source
	else
		return {
			error = "invalid sourceKind provided",
		}
	end

	local ok, outFilePath = FsUtils.MakeTemp()

	if not ok then
		return {
			error = "failed to create temporary file for darklua minification",
		}
	end

	-- [1] => sourcePath
	-- [2] => outFilePath
	return {
		res = { sourcePath, outFilePath },
	}
end

Darklua.Type = "Darklua"

Darklua.Interface = {}
Darklua.Prototype = {}

function Darklua.Prototype.ToString(self: DarkluaExtended): string
	return string.format("%s<%s>", Darklua.Type, "Global")
end

function Darklua.Prototype.IsOk(self: DarkluaExtended): boolean
	if self.darkluaPath and Fs.isFile(self.darkluaPath) then
		local isExecutable = Process.spawn(self.darkluaPath, { "--help" }, { stdio = "default" }).ok

		return isExecutable
	end

	return false
end

function Darklua.Prototype.Process(
	self: DarkluaExtended,
	sourceKind: "code" | "path",
	source: string,
	configPath: string?
): { error: string?, processed: string? }
	local initOut = __DarkluaInit(sourceKind, source)
	if initOut.error then
		return {
			error = initOut.error,
		}
	end

	local paths = initOut.res :: { string }

	local sourcePath = paths[1]
	local outFilePath = paths[2]

	local args = { "--config" }

	if configPath and configPath ~= "" then
		table.insert(args, configPath)
	else
		args = {}
	end

	local darkluaChild = Process.spawn(self.darkluaPath, { "process", sourcePath, outFilePath, table.unpack(args) })

	if not darkluaChild.ok then
		return {
			error = "darkluaChild spawning failed, error:\n" .. darkluaChild.stderr,
		}
	end

	local processedContents = Fs.readFile(outFilePath)

	return {
		processed = processedContents,
	}
end

function Darklua.Prototype.Minify(
	self: DarkluaExtended,
	sourceKind: "code" | "path",
	source: string
): { error: string?, minified: string? }
	local initOut = __DarkluaInit(sourceKind, source)
	if initOut.error then
		return {
			error = initOut.error,
		}
	end

	local paths = initOut.res :: { string }

	local sourcePath = paths[1]
	local outFilePath = paths[2]
	local darkluaChild = Process.spawn(self.darkluaPath, { "minify", sourcePath, outFilePath })

	if not darkluaChild.ok then
		return {
			error = "darkluaChild spawning failed, error:\n" .. darkluaChild.stderr,
		}
	end

	local minifiedContents = Fs.readFile(outFilePath)

	return {
		minified = minifiedContents,
	}
end

function Darklua.Interface.new(darkluaPath: string?)
	local inst = setmetatable({
		darkluaPath = darkluaPath or ProcessWhich("darklua").path,
	}, {
		__index = Darklua.Prototype,
		__type = Darklua.Type,
		__tostring = function(self: Darklua)
			return self:ToString()
		end,
	})

	return inst :: typeof(inst)
end

-- Here, we provide a path as to stop the ProcessWhich, which adds aditional
-- processing we don't need.
export type Darklua = typeof(Darklua.Interface.new("NON_EXISTENT_PATH"))

return Darklua.Interface
