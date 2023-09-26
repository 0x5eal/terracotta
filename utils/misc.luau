local _Net = require("@lune/net")
local JSONEncode, JSONDecode = _Net.jsonEncode, _Net.jsonDecode

local MiscUtils = {}

function MiscUtils.Format(formatStr: string, with: {[string]: string})
    return table.pack(string.gsub(formatStr, "\$\{(%a+)\}", function(s)
        return with[s] or ""
    end))[1]
end

function MiscUtils.PrettifyJson(json: string | {[any]: any}): string
    if typeof(json) == "table" then
        return JSONEncode(json, true)
    else
        return JSONEncode(JSONDecode(json), true)
    end
end

return MiscUtils