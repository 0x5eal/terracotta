--> Placeholder file!

local clap = require("../clap/src/clap")

local Command = clap.Command
local Opt = clap.Opt

Command.new("terracotta", true)
	:afterHelp("For more help, refer to the documentation.")
	:author("Seal Gang (0x5eal), Erica Marigold (DevComp)")
