local Darklua = require("cmd")

local Minifier = {}
export type MinfierExtended = typeof(Minifier.Prototype) & { darkluaPath: string?, darklua: Darklua.Darklua? }

Minifier.Prototype = {}
Minifier.Interface = {}
Minifier.Type = "Minifier"

function Minifier.Prototype.Minify(
	self: MinfierExtended,
	sourceKind: "code" | "path",
	sourceInner: string
): { error: string?, minified: string? }
	self.darklua = Darklua.new(self.darkluaPath)

	if self.darklua:IsOk() then
		return self.darklua:Minify("code", sourceInner)
	end

	return {
		error = "constructed darklua instance was not OK",
	}
end

function Minifier.Prototype.ToString(): string
	return string.format("%s<%s>", Minifier.Type, "{}")
end

function Minifier.Interface.new(darkluaPath: string?)
	return setmetatable({
		darkluaPath = darkluaPath,
		darklua = nil,
	}, {
		__index = Minifier.Prototype,
		__type = Minifier.Type,
		__tostring = function()
			return Minifier.Prototype.ToString()
		end,
	})
end

return Minifier.Interface
