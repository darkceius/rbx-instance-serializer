-- types.luau
-- @darkceius

local datatype = require(script.Parent.Parent.utils.datatype)
local builder = {
	id = "types",
	name = "Types",
	supports = {
		useExports = true,
	},
}

builder.__index = builder

function builder.new()
	local self = {}
	self.roots = {}
	self.lines = {}
	self.exports = {}

	self.rootDefined = {}
	self.configs = {
		useExports = true,
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
	local isRoot = meta.isRoot
	local addToExport = isRoot and self.configs.useExports
	local isDefinedAsChild = not isRoot or addToExport

	--| Setup
	local lines = {}

	if isRoot then
		if isDefinedAsChild and self.rootDefined[data.rawName] then
			return nil
		end
		self.rootDefined[data.rawName] = true
	end

	--| Instancing
	local hasChildren = #data.children > 0
	local suffix = `{hasChildren and " & {" or ""}`

	local identifier = datatype.identifier(data.rawName)
	if (identifier ~= data.rawName or data.rawName == "exports") and meta.isRoot then
		addToExport = true
		-- forced because `export type ["identifier"] = ...` isn't supported
	end

	if not isDefinedAsChild then
		table.insert(lines, `export type {identifier} = {data.className}{suffix}`)
	else
		table.insert(lines, `{identifier}: {data.className}{suffix}`)
	end

	--| Writing
	if hasChildren then
		local did = {}
		for _, child in next, data.children do
			if did[child.rawName] then
				continue
			end

			did[child.rawName] = true
			local childSource = self:instance({ isRoot = false, data = child, parent = data })
			if childSource then
				table.insert(lines, datatype.tab(childSource, 1))
			end
		end

		table.insert(lines, `}{isDefinedAsChild and "," or ""}`)
	elseif isDefinedAsChild then
		lines[1] ..= ","
	end

	local code = table.concat(lines, "\n")
	if isRoot then
		table.insert(addToExport and self.exports or self.lines, code)
	end

	return code
end

function builder.construct(self: self)
	local lines = {}

	if self.info then
		table.insert(lines, self.info)
	end

	if #self.lines > 0 then
		table.insert(lines, table.concat(self.lines, "\n"))
	end

	if #self.exports > 0 then
		table.insert(
			lines,
			table.concat({
				`export type exports = \{`,
				datatype.tab(table.concat(self.exports, "\n"), 1),
				"}",
			}, "\n")
		)
	end

	return table.concat(lines, "\n\n")
end

return builder
