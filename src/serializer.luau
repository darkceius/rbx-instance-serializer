-- serializer.luau
-- @darkceius

local assignVar = require(script.Parent.utils.assignVar)
local datatype = require(script.Parent.utils.datatype)
local keywords = require(script.Parent.utils.keywords)
local logger = require(script.Parent.utils.logger)
local properties = require(script.Parent.utils.properties)

local serializer = {}
serializer.__index = serializer

function serializer.new(builder: any?)
	local self = {}
	self.references = {}
	self.roots = {}
	self.clockStart = os.clock()
	self.index = 0

	self.builder = (builder or require("./builders/vanilla")).new()
	self.builder.roots = self.roots
	self.vars = assignVar.new()
	for k, _ in next, keywords.keywords do
		self.vars.variables[k] = 1
	end

	setmetatable(self, serializer)
	return self
end

type self = typeof(serializer.new())

function serializer.add(self: self, instance: Instance, isChild: boolean?, parent: any?)
	assert(typeof(parent) == "table" or typeof(parent) == "nil", "parent must be a: data?")
	assert(typeof(isChild) == "boolean" or typeof(isChild) == "nil", "isChild must be a: boolean?")

	local index = self.index + 1
	self.index = index

	local data = {}
	data.instance = instance
	data.parent = parent
	data.children = {}
	data.claimedNames = {}

	data.className = instance.ClassName
	data.varName = self.vars:get(datatype.toIdentifier(instance.Name))
	data.rawName = instance.Name

	data.isReferenced = false
	data.targetReferenced = false

	data._rawParent = typeof(parent) == "Instance" and parent or nil
	data._modifiedProperties = properties.getChangedProperties(instance)
	data.properties = {}

	data.instancer = {
		method = "default",
		value = nil :: string?,
	}

	if instance:IsA("MeshPart") then
		local args = {}

		table.insert(args, datatype.toString(instance.MeshId))
		table.insert(args, datatype.toString(instance.CollisionFidelity))
		table.insert(args, datatype.toString(instance.RenderFidelity))

		data.instancer.method = "set"
		data.instancer.value = `game:GetService("InsertService"):CreateMeshPartAsync({table.concat(args, ", ")})`
	elseif instance:IsA("UnionOperation") then
		logger.warn("UnionOperations aren't supported! Export them as obj and re-import them! (for your own good)")
	end

	-- index for react layoutorder
	data.targetIndex = 0

	if instance:IsA("GuiObject") then
		if data.parent then
			data.index = data.parent.targetIndex
			data.parent.targetIndex = data.index + 1
		else
			data.index = self.index
		end

		if instance.LayoutOrder > data.index then
			data.index = instance.LayoutOrder
		end
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

					data.targetReferenced = true
					target.isReferenced = true

					propertyData.isReference = true
				end
			end

			propertyData.rawValue = value -- for Rojo JSON serialization (future builder!)
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

	local elapsed = math.floor((os.clock() - self.clockStart) * 1000)

	self.builder.info = table.concat({
		"--[[",
		datatype.tab(
			table.concat({
				"# Darkceius' instance serializer",
				`* Builder: {self.builder.name} ({self.builder.id})`,
				`* Took: {elapsed} ms`,
				"",
				"* Stats:",

				datatype.toString(self.builder.stats),
			}, "\n"),
			1
		),
		"]]",
	}, "\n")

	local source = self.builder:construct()
	source ..= "\n"
	return source
end

return serializer
