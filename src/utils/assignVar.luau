local exports = {}
exports.__index = exports

function exports.new()
	local self = {}
	self.variables = {}

	setmetatable(self, exports)
	return self
end

type self = typeof(exports.new())

function exports.get(self: self, name: string): string
	local index = self.variables[name] or 0
	local newName = name

	if index ~= 0 then
		newName ..= "_" .. tostring(index + 1)
	end

	self.variables[name] = index + 1

	return newName
end

return exports
