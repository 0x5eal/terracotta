local Fs = require("@lune/fs")

local Darklua = require("cmd")
local FsUtils = require("../utils/fs")
local Codegen = require("codegen")

local Bundler = {}
export type BundlerExtended = typeof(Bundler.Prototype) & {
	darkluaPath: string?,
	darklua: Darklua.Darklua?,
	config: { contents: string, path: string? },
}
export type DarkluaRules = Codegen.Rules

Bundler.Prototype = {}
Bundler.Interface = {}
Bundler.Type = "Bundler"

function Bundler.Prototype.Bundle(
	self: BundlerExtended,
	sourceKind: "code" | "path",
	sourceInner: string
): { error: string?, processed: string? }
	self.darklua = Darklua.new(self.darkluaPath)

	if self.darklua:IsOk() then
		return self.darklua:Process(sourceKind, sourceInner, self.config.path or (function()
			local _, path = FsUtils.MakeTemp()
			Fs.writeFile(
				path,
				Codegen({
					generator = self.config.contents.generator,
					rules = self.config.contents.rules,
				})
			)

			return path
		end)())
	end

	return {
		error = "constructed darklua instance was not OK",
	}
end

function Bundler.Prototype.ToString(): string
	return string.format("%s<%s>", Bundler.Type, "{}")
end

function Bundler.Interface.new(darkluaPath: string?, opts: Codegen.Options)
	return setmetatable({
		darkluaPath = darkluaPath,
		darklua = nil,
		config = {
			contents = opts,
			path = nil,
		},
	}, {
		__index = Bundler.Prototype,
		__type = Bundler.Type,
		__tostring = function()
			return Bundler.Prototype.ToString()
		end,
	})
end

return Bundler.Interface
