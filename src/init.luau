local Fs = require("@lune/fs")

local Terracotta = require("terracotta")

Terracotta.Build({
	entryPoints = { "utils/fs.luau", "darklua/cmd.luau" },
	bundle = true,
})

-- OR --

local terracotta = Terracotta.new()

local outputs = terracotta:Build({
	entryPoints = { "utils/fs.luau", "darklua/cmd.luau" },
	bundle = true,
})

Fs.writeFile("darklua.luau", outputs["darklua/cmd.luau"])
