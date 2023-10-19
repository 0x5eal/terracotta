local Fs = require("@lune/fs")

local Terracotta = require("..")

Terracotta.Build({
	entryPoints = { "utils/fs.luau", "darklua/cmd.luau" },
	bundle = true,
})

-- OR --

local terracotta = Terracotta.new()

local outputs = terracotta:Build({
	entryPoints = { "utils/fs.luau", "darklua/cmd.luau" },
	bundle = true,
	rules = {
		"remove_spaces",
		"remove_comments",
		"rename_variables",
		"rename_variables",
	},
})

Fs.writeFile("darklua.luau", outputs["darklua/cmd.luau"])
