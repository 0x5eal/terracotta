local spawn = require("@lune/process").spawn
local stdio = require("@lune/stdio")
local fs = require("@lune/fs")
local task = require("@lune/task")

local codegen = require("../darklua/codegen")

local WAX_PREFIX_FORMAT = function(type: "error" | "info", scope: string?)
	return stdio.color(if type == "error" then "red" else "green") .. (scope or "[wax]") .. stdio.color("reset")
end

local LARGE_SCALE_FACTOR = 5.5
local REGULAR_SCALE_FACTOR = 4

local BoxifyOutput = function(msg: string)
	local pad = (" "):rep(#msg / 2)

	if msg:find("\n") then
		local lines = msg:split("\n")
		local paddingNum = 0

		for _, line in lines do
			if paddingNum and #line > paddingNum then
				paddingNum = math.round(#line / 2)
			end
		end

		pad = (" "):rep(paddingNum)

		local processedLines = {}

		for k, line in lines do
			local paddedMsg = pad .. line .. (" "):rep((paddingNum * LARGE_SCALE_FACTOR) - paddingNum - utf8.len(line))

			-- This is a hack for outputs made by wax, if the first line contains
			-- "creating directory"
			if line:find("Creating directory") and k == 1 then
				paddedMsg ..= "        "
			end

			table.insert(processedLines, "┃" .. paddedMsg .. "┃")
		end

		print("┏" .. ("━"):rep(paddingNum * LARGE_SCALE_FACTOR) .. "┓")
		print(table.concat(processedLines, "\n"))
		print("┗" .. ("━"):rep(paddingNum * LARGE_SCALE_FACTOR) .. "┛")
	else
		print("┏" .. ("━"):rep(#msg * REGULAR_SCALE_FACTOR) .. "┓")
		print("┃" .. pad .. msg .. pad .. " " .. "┃")
		print("┗" .. ("━"):rep(#msg * REGULAR_SCALE_FACTOR) .. "┛")
	end
end

if not fs.isDir("dist/") then
	fs.writeDir("dist/")
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

local loader = task.spawn(function()
	local chars = { "-", "\\", "|", "/" }
	local isFirstRun = true

	stdio.write(`{WAX_PREFIX_FORMAT("info", "[build]")} Building with terracotta with wax...     `)

	while true do
		for _, char in chars do
			task.wait(0.1)

			if not isFirstRun then
				stdio.write("\b")
			end

			stdio.write(char)

			isFirstRun = false
		end
	end
end)

task.spawn(function()
	local child = spawn("lune", {
		"wax",
		"bundle",
		"input=default.project.json",
		"verbose=true",
		"minify=true",
		"ci-mode=true",
		"output=dist/terracotta.luau",
	})

	task.cancel(loader)
	print("\b \n")

	BoxifyOutput(child.stdout)

	if not child.ok then
		print()
		print(`{WAX_PREFIX_FORMAT("error")} Exited with code {child.code}.`)
	else
		print()
		print(`{WAX_PREFIX_FORMAT("info")} Successfully built terracotta.luau!`)
	end

	fs.removeFile(".darklua.json5")
end)
