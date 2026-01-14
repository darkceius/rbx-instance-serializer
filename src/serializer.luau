local datatype = require("./utils/datatype")
local properties = require("./utils/properties")

local serializer = {}
serializer.__index = serializer

function serializer.new(builder: any?)
	local self = {}
	self.references = {}
	self.roots = {}
	self.variables = {}

	self.builder = (builder or require("./builders/vanilla")).new()
	self.builder.roots = self.roots

	setmetatable(self, serializer)
	return self
end

type self = typeof(serializer.new())

function serializer.assignVar(self: self, name: string)
	local index
	local t = self.variables[name] or 0
	if t then
		index = t
	end

	if index ~= 0 then
		name ..= tostring(index + 1)
	end

	self.variables[name] = t + 1

	return name
end

function serializer.add(self: self, instance: Instance, isChild: boolean?, parent: any?)
	assert(typeof(parent) == "table" or typeof(parent) == "nil", "parent must be a: data?")
	assert(typeof(isChild) == "boolean" or typeof(isChild) == "nil", "isChild must be a: boolean?")

	local data = {}
	data.instance = instance
	data.parent = parent
	data.children = {}

	data.className = instance.ClassName
	data.varName = self:assignVar(datatype.toIdentifier(instance.Name))

	data.isReferenced = false

	data._modifiedProperties = properties.getChangedProperties(instance)
	data.properties = {}

	-- index for roact layoutorder
	if data.parent then
		data.index = data.parent.index
		data.parent.index += 1
	else
		data.index = 1
	end

	function data.init()
		for _, propertyName in next, data._modifiedProperties do
			local value = (data.instance :: any)[propertyName]
			local shouldSerialize = true
			local propertyData = {}
			propertyData.isReference = false

			if typeof(value) == "Instance" then
				local target = self.references[value]

				if target then
					shouldSerialize = false
					value = target.varName

					data.isReferenced = true
					target.isReferenced = true

					propertyData.isReference = true
				end
			end

			propertyData.valueType = typeof(value)
			propertyData.name = propertyName
			propertyData.serialized = shouldSerialize and datatype.toString(value) or value

			table.insert(data.properties, propertyData)
		end

		for _, v in next, data.children do
			task.spawn(v.init)
		end
	end

	self.references[instance] = data

	for _, inst in next, instance:GetChildren() do
		table.insert(data.children, self:add(inst, true, data))
	end

	if not isChild then
		table.insert(self.roots, data)
	end

	return data
end

function serializer.serialize(self: self)
	self.builder:init()
	return self.builder:construct()
end

return serializer
