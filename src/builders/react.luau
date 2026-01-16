-- react.luau
-- @darkceius

local assignVar = require(script.Parent.Parent.utils.assignVar)
local datatype = require(script.Parent.Parent.utils.datatype)
local builder = {
	id = "react",
	name = "React",
	supports = {
		useExports = true,
		useProperties = true,
		useAutoLayoutOrder = true,
	},
}

builder.__index = builder

function builder.new()
	local self = {}
	self.headers = {
		"local react = nil -- provide react lib here",
		"local e = react.createElement",
	}

	self.references = {}

	self.roots = {}
	self.lines = {}

	self.configs = {
		useExports = true,
		useAutoLayoutOrder = true,
	}

	self.info = nil :: string?
	self.stats = {
		instances = 0,
	}

	setmetatable(self, builder)
	return self
end

type self = typeof(builder.new())

function builder.init(self: self)
	local roots = self.roots

	for _, v in next, roots do
		v.init()
	end

	for _, v in next, roots do
		self:instance({
			isRoot = true,
			data = v,
		})
	end
end

function builder.instance(
	self: self,
	meta: {
		isRoot: boolean,
		data: any,
		parent: any,
	}
): string?
	self.stats.instances += 1

	local data = meta.data
	local variableName = data.varName
	local isRoot = meta.isRoot
	local isReferenced = data.isReferenced

	--| Setup
	local lines = {}

	if isReferenced then
		table.insert(self.references, variableName)

		table.insert(data.properties, {
			raw = `ref = ref_{data.varName},`,
			valueType = "Instance",
		})
	end

	--| Instancing
	local elementArgs = {}
	local propertiesLines = {}
	local childrenLines = {}

	if data.instancer.method == "default" then
		table.insert(elementArgs, datatype.toString(data.className))
	elseif data.instancer.method == "set" then
		table.insert(self.lines, `local {data.varName} = nil -- MeshPart creation is not supported yet!`)
		return
	else
		error("Unknown instancer method")
	end

	--| Properties
	local customLayoutOrder = false
	if data.instance:IsA("GuiObject") and data.index then
		customLayoutOrder = true
		table.insert(data.properties, {
			raw = `LayoutOrder = {datatype.toString(data.index)},`,
			valueType = "number",
		})
	end

	table.sort(data.properties, function(a, b)
		return a.valueType > b.valueType
	end)

	for i = #data.properties, 1, -1 do
		local property = data.properties[i]

		if property.name == "Name" or (customLayoutOrder and property.name == "LayoutOrder") then
			table.remove(data.properties, i)
		end
	end

	if #data.properties > 0 then
		table.insert(propertiesLines, "{")

		for
			_,
			property: {
			serialized: string | any,
			name: string,
			isReference: boolean,
			raw: string,
		}
		in next, data.properties do
			if property.raw then
				table.insert(propertiesLines, datatype.tab(property.raw, 1))
				continue
			end

			local identifier = datatype.identifier(property.name)
			local value = `{identifier} = {property.serialized},`

			if property.isReference then
				value = `{identifier} = ref_{property.serialized},`
			end

			table.insert(propertiesLines, datatype.tab(value, 1))
		end

		table.insert(propertiesLines, "}")
	else
		propertiesLines = { "{}" }
	end

	--| Children
	if #data.children > 0 then
		table.insert(childrenLines, "{")

		local vars = assignVar.new()

		for _, child in next, data.children do
			local childSource = self:instance({ isRoot = false, data = child, parent = data })
			if childSource then
				table.insert(
					childrenLines,
					datatype.tab(`{datatype.identifier(vars:get(child.rawName))} = {childSource},`, 1)
				)
			end
		end

		table.insert(childrenLines, "}")
	else
		childrenLines = { "{}" }
	end

	--| Finishing up
	if #propertiesLines > 1 or #childrenLines > 1 then
		table.insert(elementArgs, table.concat(propertiesLines, "\n"))
	end

	if #childrenLines > 1 then
		table.insert(elementArgs, table.concat(childrenLines, "\n"))
	end

	table.insert(lines, `{isRoot and `local {data.varName} = ` or ""}e({table.concat(elementArgs, ", ")})`)

	local code = table.concat(lines, "\n")
	if isRoot then
		table.insert(self.lines, code)
	end

	return code
end

function builder.construct(self: self)
	local lines = {}

	if self.info then
		table.insert(lines, self.info)
	end

	if #self.headers > 0 then
		table.insert(lines, table.concat(self.headers, "\n"))
	end

	if #self.references > 0 then
		local refs = {}
		for _, v in next, self.references do
			table.insert(refs, "react.useRef(nil)")
		end

		local vars = {}
		for _, v in next, self.references do
			table.insert(vars, `ref_{v}`)
		end

		table.insert(lines, `local {table.concat(vars, ", ")} = {table.concat(refs, ", ")}`)
	end

	if #self.lines > 0 then
		table.insert(lines, table.concat(self.lines, "\n"))
	end

	if #self.roots > 0 then
		if self.configs.useExports then
			local roots = {}
			for _, v in next, self.roots do
				table.insert(roots, `{v.varName} = {v.varName},`)
			end

			table.insert(lines, `return \{\n{datatype.tab(table.concat(roots, "\n"), 1)}\n\}`)
		end
	end

	return table.concat(lines, "\n\n")
end

return builder
