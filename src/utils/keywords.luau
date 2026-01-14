-- taken from Ozzypig's repr (WTFPL license)
-- https://github.com/Ozzypig/repr/blob/master/repr.lua

local exports = {}

exports.keywords = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true,
}

function exports.isIdentifier(str: any): boolean
	if type(str) ~= "string" then
		return false
	end

	if str:len() == 0 then
		return false
	end

	if str:find("[^%d%a_]") then
		return false
	end

	if tonumber(str:sub(1, 1)) then
		return false
	end

	if exports.keywords[str] then
		return false
	end

	return true
end

return exports
