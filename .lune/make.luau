local spawn = require("@lune/process").spawn
local stdio = require("@lune/stdio")
local fs = require("@lune/fs")

local codegen = require("../darklua/codegen")

local WAX_PREFIX_FORMAT = function(type: "error" | "info", scope: string?)
	return stdio.color(if type == "error" then "red" else "green") .. (scope or "[wax]") .. stdio.color("reset")
end

print(`{WAX_PREFIX_FORMAT("info", "[codegen]")} Generating darklua config file at darklua.config.json`)
fs.writeFile(
	".darklua.json5",
	codegen({
		generator = "dense",
		rules = {
			"remove_spaces",
			"rename_variables",
		},
	})
)

print()
print("------------------------------------------------------------------")

codegen({
	rules = {
		"config",
	},
})

local child = spawn(
	"lune",
	{ "wax", "bundle", "input=default.project.json", "verbose=true", "minify=true", "output=terracotta.luau" },
	{
		stdio = "inherit",
	}
)

print("------------------------------------------------------------------")

if not child.ok then
	print()
	print(`{WAX_PREFIX_FORMAT("error")} Exited with code {child.code}.`)
else
	print()
	print(`{WAX_PREFIX_FORMAT("info")} Successfully built terracotta.luau!`)
end

fs.removeFile(".darklua.json5")
