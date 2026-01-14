local builder = {}
builder.__index = builder

function builder.new()
	local self = {}

	setmetatable(self, builder)
	return self
end

type self = typeof(builder.new())

return builder
