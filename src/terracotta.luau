local Darklua = require("../darklua")
local Codegen = require("../darklua/codegen")

local Terracotta = {}
Terracotta.Interface = {}
Terracotta.Prototype = {}

type DarkluaRules = Codegen.Rules

export type Terracotta = typeof(Terracotta) & {
	bundler: Darklua.Bundler,
	minifier: Darklua.Minifier,
}

function Terracotta.Prototype.Build(
	self: Terracotta?,
	opts: {
		entryPoints: { string },
		bundle: boolean?,
		outFile: string?,
		rules: { DarkluaRules }?,
	}
)
	local bundler: Darklua.Bundler

	if self ~= nil and self.bundler ~= nil then
		bundler = self.bundler
	else
		bundler = Darklua.bundler.new(nil, {
			generator = "dense",
			sources = opts.entryPoints,
			outFile = opts.outFile,
			requireMode = (opts.bundle and "path") or nil,
			rules = opts.rules or {
				"remove_comments",
				"rename_variables",
				"remove_spaces",
			},
		})
	end

	local builtOuts = {}

	for _, path in opts.entryPoints do
		local out = bundler:Bundle("path", path)

		if out.error ~= nil then
			error(out.error)
		end

		builtOuts[path] = out.processed
	end

	return builtOuts
end

function Terracotta.Interface.new()
	return setmetatable({
		minifier = nil,
		bundler = nil,
	}, {
		__index = Terracotta.Prototype,
	})
end

function Terracotta.Interface.Build(opts: { bundle: boolean?, entryPoints: { string }, outFile: string? })
	return Terracotta.Prototype.Build(nil, opts)
end

return Terracotta.Interface
