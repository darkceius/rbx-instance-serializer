-- vanilla.luau
-- @darkceius

local datatype = require(script.Parent.Parent.utils.datatype)
local builder = {
	id = "vanilla",
	name = "Vanilla",
	supports = {
		wrapChildren = true,
		useExports = true,
		parentRoots = true,
		useProperties = true,
		useNameProperty = true,
	},
}

builder.__index = builder

function builder.new()
	local self = {}
	self.headers = {}
	self.footers = {}
	self.roots = {}
	self.lines = {}

	self.configs = {
		useExports = true,
		parentRoots = false,

		-- recommended to avoid local variable register limit
		wrapChildren = true,
	}

	self.info = nil :: string?
	self.stats = {
		instances = 0,
		blocks = 0,
		main_locals = 0,
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
)
	self.stats.instances += 1

	local data = meta.data
	local variableName = data.varName

	--| Setup
	local lines = {}

	table.sort(data.properties, function(a, b)
		return a.valueType > b.valueType
	end)

	--| Instancing
	local isReferenced = data.isReferenced and not meta.isRoot
	local instancer
	do
		if isReferenced then
			self.stats.main_locals += 1
			table.insert(self.headers, variableName)
		end

		if data.instancer.method == "default" then
			instancer = `Instance.new({datatype.toString(data.className)})`
		elseif data.instancer.method == "set" then
			instancer = data.instancer.value
		end
	end

	table.insert(lines, `{not isReferenced and "local " or ""}{variableName} = {instancer}`)

	--| Properties
	for _, property: {
		serialized: string | any,
		name: string,
		isReference: boolean,
	} in
		next,
		data.properties
	do
		local value = `{variableName}{datatype.index(property.name)} = {property.serialized}`

		if property.isReference then
			table.insert(self.footers, value)
			continue
		end

		table.insert(lines, value)
	end

	--| Children
	if #data.children > 0 then
		local wrapChildren = self.configs.wrapChildren

		if wrapChildren then
			table.insert(lines, "do")
			self.stats.blocks += 1
		end

		for _, child in next, data.children do
			local childSource = self:instance({ isRoot = false, data = child, parent = data })

			table.insert(lines, datatype.tab(childSource, wrapChildren and 1 or 0))
		end

		if wrapChildren then
			table.insert(lines, "end")
		end
	end

	--| Parent
	if meta.parent then
		table.insert(lines, `{variableName}{datatype.index("Parent")} = {meta.parent.varName}`)
	end

	local code = table.concat(lines, "\n")
	if meta.isRoot then
		table.insert(self.lines, code)
		self.stats.main_locals += 1
	elseif not self.configs.wrapChildren and not isReferenced then
		self.stats.main_locals += 1
	end

	return code
end

function builder.construct(self: self)
	local lines = {}

	if self.info then
		table.insert(lines, self.info)
	end

	if #self.headers > 0 then
		table.insert(lines, `local {table.concat(self.headers, ", ")}`)
	end

	if #self.lines > 0 then
		table.insert(lines, table.concat(self.lines, "\n"))
	end

	if #self.footers > 0 then
		table.insert(lines, table.concat(self.footers, "\n"))
	end

	if #self.roots > 0 then
		if self.configs.parentRoots then
			for _, root in next, self.roots do
				if not root._rawParent then
					continue
				end

				table.insert(lines, `{root.varName}{datatype.index("Parent")} = {datatype.toString(root._rawParent)}`)
			end
		end

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
