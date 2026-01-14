local properties = require("./utils/properties")

-- TODO
-- work on this

local serializer = {}
serializer.__index = serializer

function serializer.new()
	local self = {}
	self.references = {}
	self.roots = {}

	self.builder = require("./builders/vanilla").new()

	setmetatable(self, serializer)
	return self
end

type self = typeof(serializer.new())

function serializer.parse(self: self, instance: Instance, isChild: boolean?)
	local data = {}
	data.children = {}
	data.className = instance.ClassName
	data.properties = properties.getProperties(data.className)
	data.propertiesToWrite = properties.getChangedProperties(instance)
	data.requiredInstances = {}

	data.isChild = not not isChild
	data.isUsed = false
	data.job = self
	data.source = nil :: string?

	function data.init()
		for _, v in next, data.children do
			task.spawn(v.init)
		end

		print(instance, "started!")
	end

	self.references[instance] = data

	for _, inst in next, instance:GetChildren() do
		table.insert(data.children, self:parse(inst, true))
	end

	if not isChild then
		table.insert(self.roots, data)
	end

	return data
end

function serializer.start(self: self)
	for _, v in next, self.roots do
		v.init()
	end
end

return serializer
