local Bundler = require("bundler")
local Minifier = require("minifier")

export type Bundler = Bundler.BundlerExtended
export type Minifier = Minifier.MinfierExtended

local Darklua = {
	bundler = Bundler,
	minifier = Minifier,
	__cmd = require("cmd"),
}

return Darklua
