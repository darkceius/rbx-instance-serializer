-- datatype.luau
-- @darkceius
--!optimize 2

--[[
	TODO:
	- tests
	- define SharedTable
]]

local EncodingService = game:GetService("EncodingService")
local capabilities = require(script.Parent.capabilities)
local keywords = require(script.Parent.keywords)
local round = require(script.Parent.round)

local exports = {}
exports.config = {
	escapeNewline = false,

	roundNumbers = true,
	numberPrecision = nil,

	hideCyclicTables = false,
	cyclicLabel = "*cylic*",
}

function exports.identifier(target: any | string, ...): (string, boolean)
	if not keywords.isIdentifier(target) then
		return `[{exports.toString(target, ...)}]`, true
	end

	return target, false
end

function exports.index(target: any)
	local result, sanitized = exports.identifier(target, { isIndex = true })

	if sanitized then
		return result
	end

	return `.{result}`
end

function exports.toIdentifier(target: string)
	local sanitized = string.gsub(target, "(%l)(%u)", "%1 %2")
	sanitized = string.gsub(sanitized, "[^%a%d]", " ")

	local words = {}

	for word in string.gmatch(sanitized, "%S+") do
		table.insert(words, string.lower(word))
	end

	if #words == 0 then
		return string.format("_%x", math.random(0, 0xFFFF))
	end

	local result = words[1]
	for i = 2, #words do
		result ..= string.upper(string.sub(words[i], 1, 1)) .. string.sub(words[i], 2)
	end

	if string.match(result, "^%d") then
		result = "_" .. result
	end

	return result
end

function exports.numberSnap(num: number, threshold: number?)
	local nearest = math.floor(num + 0.5)

	if math.abs(num - nearest) < (threshold or 0.0001) then
		return nearest
	end

	return num
end

function exports.isArray(array: { [any]: any })
	local len = #array

	for k, v in next, array do
		if typeof(k) ~= "number" then
			return false
		end

		if k > len then
			return false
		end
	end

	return true
end

function exports.tab(str: string, tabLength: number)
	if tabLength <= 0 then
		return str
	end

	local tab = string.rep("\t", tabLength)
	local lines = string.split(str, "\n")

	for k, v in next, lines do
		lines[k] = tab .. v
	end

	return table.concat(lines, "\n")
end

function exports.isUDim2Empty(udim2: UDim2)
	return udim2.X.Offset == 0 and udim2.Y.Offset == 0 and udim2.X.Scale == 0 and udim2.Y.Scale == 0
end

local blankHandler = function(target, convert)
	return convert(tostring(target))
end

exports.types = {
	--| Lua Types
	["nil"] = function()
		return "nil"
	end,

	number = function(target: number)
		-- NaN
		if target ~= target then
			return "0 / 0"
		end

		-- converting -0 to 0
		if target == 0 then
			target = 0
		end

		-- math.huge
		local huge = math.huge
		if target >= huge then
			return "math.huge"
		elseif target <= -huge then
			return "-math.huge"
		end

		-- normal number
		if exports.config.roundNumbers then
			return tostring(exports.numberSnap(round(target, exports.config.numberPrecision)))
		end

		return tostring(target)
	end,

	string = function(target: string, _, _meta)
		local meta: { minPadding: number?, isIndex: boolean? } = _meta or {}
		local minPadding = meta.minPadding or 0

		local wrapper = {} :: { string }

		if exports.config.escapeNewline then
			target = string.gsub(target, "\n", function()
				return "\\n"
			end)
		end

		if string.match(target, "\n") then
			local requiredPadding = 0
			for equals in string.gmatch(target, "]%s*(=*)%s*]") do
				if #equals >= requiredPadding then
					requiredPadding = #equals + 1
				end
			end

			local padding = string.rep("=", math.max(requiredPadding, minPadding))
			local space = meta.isIndex and " " or ""

			wrapper = { `{space}[{padding}[`, `]{padding}]{space}` }
		elseif not string.match(target, '"') then
			wrapper = { '"' }
		elseif not string.match(target, "'") then
			wrapper = { "'" }
		else
			wrapper = { '"' }
			target = string.gsub(target, '"', function(a)
				return "\\" .. a
			end)
		end

		return `{wrapper[1]}{target}{wrapper[2] or wrapper[1]}`
	end,

	boolean = function(target: boolean)
		return target and "true" or "false"
	end,

	table = function(target: { [any]: any }, convert, _meta)
		local meta: { cyclic: any, isIndex: boolean? } = _meta or {}

		if not next(target) then
			return "{}"
		end

		if exports.isArray(target) then
			local t = {}
			for k, v in next, target do
				table.insert(t, convert(v, meta))
			end
			return `\{{table.concat(t, ", ")}\}`
		end

		local cyclic = meta.cyclic or {}
		cyclic[target] = true

		meta.isIndex = true
		meta.cyclic = cyclic

		local lines = {}
		for k, v in next, target do
			if exports.config.hideCyclicTables then
				if cyclic[k] or cyclic[v] then
					continue
				end
			else
				if cyclic[k] then
					k = exports.config.cyclicLabel
				end

				if cyclic[v] then
					v = exports.config.cyclicLabel
				end
			end

			table.insert(lines, `{exports.identifier(k, meta)} = {convert(v, meta)},`)
		end

		if #lines == 0 then
			return "{}"
		end

		return `\{\n{exports.tab(table.concat(lines, "\n"), 1)}\n\}`
	end,

	vector = function(target: vector, convert)
		for _, v in
			next,
			{
				{ vector.zero, "vector.zero" },
				{ -vector.zero, "-vector.zero" },
				{ vector.one, "vector.one" },
				{ -vector.one, "-vector.one" },
			} :: { { any } }
		do
			if target == v[1] then
				return v[2]
			end
		end

		local args = {}

		for _, v in next, { "x", "y", "z" } do
			table.insert(args, convert((target :: any)[v]))
		end

		return `vector.new({table.concat(args, ", ")})`
	end,

	["function"] = blankHandler,
	thread = blankHandler,
	userdata = blankHandler,

	buffer = function(target: buffer, convert)
		return `game:GetService("EncodingService"):Base64Decode(buffer.fromstring({convert(
			buffer.tostring(EncodingService:Base64Encode(target))
		)}))`
	end,

	--| Engine Types
	Axes = function(target: Axes, convert)
		local args = {}

		-- Axis
		for _, enum in next, Enum.Axis:GetEnumItems() do
			if (target :: any)[enum.Name] == true then
				table.insert(args, convert(enum))
			end
		end

		-- Normal IDs
		for _, enum in next, Enum.NormalId:GetEnumItems() do
			if (target :: any)[enum.Name] == true then
				table.insert(args, convert(enum))
			end
		end

		return `Axes.new({table.concat(args, ", ")})`
	end,

	BrickColor = function(target: BrickColor, convert)
		return `BrickColor.new({convert(target.Name)})`
	end,

	CatalogSearchParams = function(target: CatalogSearchParams, convert)
		local base = CatalogSearchParams.new()
		local properties = {
			{ "SearchKeyword", base.SearchKeyword },
			{ "MinPrice", base.MinPrice },
			{ "MaxPrice", base.MaxPrice },
			{ "SortType", base.SortType },
			{ "SortAggregation", (base :: any).SortAggregation },
			{ "CategoryFilter", base.CategoryFilter },
			{ "SalesTypeFilter", (base :: any).SalesTypeFilter },
			{ "BundleTypes", base.BundleTypes },
			{ "AssetTypes", base.AssetTypes },
			{ "IncludeOffSale", (base :: any).IncludeOffSale },
			{ "CreatorName", (base :: any).CreatorName },
			{ "CreatorType", (base :: any).CreatorType },
			{ "CreatorId", (base :: any).CreatorId },
			{ "Limit", (base :: any).Limit },
		} :: { { any } }

		local lines = {}
		table.insert(lines, "local params = CatalogSearchParams.new()")

		for _, data in next, properties do
			local propertyName, propertyDefault = unpack(data)
			local current = (target :: any)[propertyName]
			if current == propertyDefault then
				continue
			end

			if typeof(current) == "table" and exports.isArray(current) then
				local isModified = false
				for _, v in next, current do
					if not table.find(propertyDefault, v) then
						isModified = true
					end
				end

				if not isModified then
					continue
				end
			end

			table.insert(lines, `params{exports.index(propertyName)} = {convert(current)}`)
		end

		table.insert(lines, "return params")

		base = nil :: any

		if #lines == 2 then
			return `CatalogSearchParams.new()`
		else
			local body = table.concat(lines, "\n")
			return `(function()\n{exports.tab(body, 1)}\nend)()`
		end
	end,

	CFrame = function(target: CFrame, convert)
		if target == CFrame.identity then
			return "CFrame.identity"
		end

		local position = target.Position.Magnitude ~= 0 and `CFrame.new({convert(target.Position)})`
		local orientation

		local angles = { target:ToEulerAnglesXYZ() }
		if angles[1] ~= 0 or angles[2] ~= 0 or angles[3] ~= 0 then
			local args = {}
			for i = 1, 3 do
				table.insert(args, angles[i] ~= 0 and `math.rad({convert(math.deg(angles[i]))})` or `0`)
			end

			orientation = `CFrame.fromEulerAnglesXYZ({table.concat(args, ", ")})`
		end

		return `{position or ""}{(orientation and position) and " * " or ""}{orientation or ""}`
	end,

	Color3 = function(target: Color3, convert)
		local args = {}

		table.insert(args, convert(math.floor(target.R * 255)))
		table.insert(args, convert(math.floor(target.G * 255)))
		table.insert(args, convert(math.floor(target.B * 255)))

		return `Color3.fromRGB({table.concat(args, ", ")})`
	end,

	ColorSequence = function(target: ColorSequence, convert)
		local keypoints = target.Keypoints

		if #keypoints == 1 then
			return `ColorSequence.new({convert(keypoints[1].Value)})`
		elseif #keypoints == 2 then
			return `ColorSequence.new({convert(keypoints[1].Value)}, {convert(keypoints[2].Value)})`
		end

		local args = {}
		for k, v in next, keypoints do
			table.insert(args, v)
		end

		return `ColorSequence.new({convert(args)})`
	end,

	ColorSequenceKeypoint = function(target: ColorSequenceKeypoint, convert)
		return `ColorSequenceKeypoint.new({convert(target.Time)}, {convert(target.Value)})`
	end,

	Content = function(target: Content, convert)
		if target.SourceType == Enum.ContentSourceType.None then
			return `Content.none`
		elseif target.SourceType == Enum.ContentSourceType.Object then
			return `Content.fromObject({convert(target.Object)})`
		elseif target.SourceType == Enum.ContentSourceType.Uri then
			return `Content.fromUri({convert(target.Uri)})`
		end

		return "Content.none --[[ failed to parse ]]"
	end,

	DateTime = function(target: DateTime, convert)
		return `DateTime.fromUnixTimestampMillis({convert(target.UnixTimestampMillis)})`
	end,

	DockWidgetPluginGuiInfo = function(target: DockWidgetPluginGuiInfo, convert)
		-- for some reason you cant index this datatype at all
		-- but it does give data when tostring()'ing it!

		local properties = {}
		for key, value in string.gmatch(tostring(target), "(%w+):(%w+)") do
			properties[key] = value
		end

		local args = {}

		table.insert(args, convert(Enum.InitialDockState:FromName(properties.InitialDockState or "")))
		table.insert(args, convert(properties.InitialEnabled == "1" and true or false))
		table.insert(args, convert(properties.InitialEnabledShouldOverrideRestore == "1" and true or false))
		table.insert(args, convert(tonumber(properties.FloatingXSize) or 0))
		table.insert(args, convert(tonumber(properties.FloatingYSize) or 0))
		table.insert(args, convert(tonumber(properties.MinWidth) or 0))
		table.insert(args, convert(tonumber(properties.MinHeight) or 0))

		return `DockWidgetPluginGuiInfo.new({table.concat(args, ", ")})`
	end,

	Enum = function(target: Enum)
		local enumName = tostring(target)
		return `Enum{exports.index(enumName)}`
	end,

	EnumItem = function(target: EnumItem)
		local enumName = tostring(target.EnumType)
		local itemName = target.Name

		return `Enum{exports.index(enumName)}{exports.index(itemName)}`
	end,

	Enums = function(_: Enums)
		return "Enum"
	end,

	Faces = function(target: Faces, convert)
		local args = {}

		for _, enum in next, Enum.NormalId:GetEnumItems() do
			if (target :: any)[enum.Name] == true then
				table.insert(args, convert(enum))
			end
		end

		return `Faces.new({table.concat(args, ", ")})`
	end,

	FloatCurveKey = function(target: FloatCurveKey, convert)
		local args = {}

		table.insert(args, convert(target.Time))
		table.insert(args, convert(target.Value))

		if target.Interpolation ~= Enum.KeyInterpolationMode.Cubic then
			table.insert(args, convert(target.Interpolation))
		end

		return `FloatCurveKey.new({table.concat(args, ", ")})`
	end,

	Font = function(target: Font, convert)
		local styleDiff = target.Style ~= Enum.FontStyle.Normal
		local weightDiff = target.Weight ~= Enum.FontWeight.Regular or styleDiff

		--| By families
		local nameFamilies = {}
		for _, font in next, Enum.Font:GetEnumItems() do
			nameFamilies[Font.fromName(font.Name).Family] = font
		end

		local function addRemainingArgs(args)
			if weightDiff then
				table.insert(args, convert(target.Weight))
			end

			if styleDiff then
				table.insert(args, convert(target.Style))
			end
		end

		if nameFamilies[target.Family] then
			local args = {}

			table.insert(args, convert(nameFamilies[target.Family].Name))
			addRemainingArgs(args)

			return `Font.fromName({table.concat(args, ", ")})`
		end

		--| By asset
		local args = {}

		table.insert(args, convert(target.Family))
		addRemainingArgs(args)

		return `Font.new({table.concat(args, ", ")})`
	end,

	Instance = function(target: Instance, convert)
		if not target:IsDescendantOf(game) then
			return "nil"
		end

		local parents = {}
		local current = target :: Instance?

		while true do
			if not current then
				break
			end

			if current == workspace then
				table.insert(parents, "workspace")
				break
			elseif current.Parent == game and current:IsA("ServiceProvider") then
				table.insert(parents, `game:GetService({convert(current.ClassName)})`)
				break
			elseif current == game then
				table.insert(parents, "game")
				break
			end

			table.insert(parents, current.Name)

			current = current.Parent
		end

		local reverse = {}
		for i = #parents, 1, -1 do
			table.insert(reverse, parents[i])
		end

		local path = ""

		for i, v in next, reverse do
			if i == 1 then
				path ..= v
				continue
			end

			path ..= exports.index(v)
		end

		return path
	end,

	NumberRange = function(target: NumberRange, convert)
		if target.Max == target.Min then
			return `NumberRange.new({convert(target.Min)})`
		end

		return `NumberRange.new({convert(target.Min)}, {convert(target.Max)})`
	end,

	NumberSequence = function(target: NumberSequence, convert)
		local keypoints = target.Keypoints

		if #keypoints == 1 then
			return `NumberSequence.new({convert(keypoints[1].Value)})`
		elseif #keypoints == 2 then
			if keypoints[1].Value == keypoints[2].Value then
				return `NumberSequence.new({convert(keypoints[1].Value)})`
			end

			return `NumberSequence.new({convert(keypoints[1].Value)}, {convert(keypoints[2].Value)})`
		end

		local args = {}
		for k, v in next, keypoints do
			table.insert(args, v)
		end

		return `NumberSequence.new({convert(args)})`
	end,

	NumberSequenceKeypoint = function(target: NumberSequenceKeypoint, convert)
		if target.Envelope ~= 0 then
			return `NumberSequenceKeypoint.new({convert(target.Time)}, {convert(target.Value)}, {convert(
				target.Envelope
			)})`
		end

		return `NumberSequenceKeypoint.new({convert(target.Time)}, {convert(target.Value)})`
	end,

	OverlapParams = function(target: OverlapParams, convert)
		local base = OverlapParams.new()
		local properties = {
			{ "FilterDescendantsInstances", base.FilterDescendantsInstances },
			{ "FilterType", base.FilterType },
			{ "MaxParts", base.MaxParts },
			{ "CollisionGroup", base.CollisionGroup },
			{ "Tolerance", (base :: any).Tolerance },
			{ "RespectCanCollide", base.RespectCanCollide },
			{ "BruteForceAllSlow", base.BruteForceAllSlow },
		} :: { { any } }

		local lines = {}
		table.insert(lines, "local params = OverlapParams.new()")

		for _, data in next, properties do
			local propertyName, propertyDefault = unpack(data)
			local current = (target :: any)[propertyName]
			if current == propertyDefault then
				continue
			end

			if typeof(current) == "table" and exports.isArray(current) then
				local isModified = false
				for _, v in next, current do
					if not table.find(propertyDefault, v) then
						isModified = true
					end
				end

				if not isModified then
					continue
				end
			end

			table.insert(lines, `params{exports.index(propertyName)} = {convert(current)}`)
		end

		table.insert(lines, "return params")

		base = nil :: any

		if #lines == 2 then
			return `OverlapParams.new()`
		else
			local body = table.concat(lines, "\n")
			return `(function()\n{exports.tab(body, 1)}\nend)()`
		end
	end,

	Path2DControlPoint = function(target: Path2DControlPoint, convert)
		local emptyRightTangent = exports.isUDim2Empty(target.RightTangent)
		local emptyLeftTangent = exports.isUDim2Empty(target.LeftTangent) and emptyRightTangent
		local emptyPosition = exports.isUDim2Empty(target.Position)

		if emptyLeftTangent and emptyRightTangent and emptyPosition then
			return "Path2DControlPoint.new()"
		end

		local args = {}

		table.insert(args, convert(target.Position))

		if not emptyLeftTangent then
			table.insert(args, convert(target.LeftTangent))
		end

		if not emptyRightTangent then
			table.insert(args, convert(target.RightTangent))
		end

		return `Path2DControlPoint.new({table.concat(args, ", ")})`
	end,

	PathWaypoint = function(target: PathWaypoint, convert)
		local args = {}

		table.insert(args, convert(target.Position))
		table.insert(args, convert(target.Action))
		if target.Label ~= "" then
			table.insert(args, convert(target.Label))
		end

		return `PathWaypoint.new({table.concat(args, ", ")})`
	end,

	PhysicalProperties = function(target: PhysicalProperties, convert)
		-- Checking for material variants
		for _, material in next, Enum.Material:GetEnumItems() do
			local phys = PhysicalProperties.new(material)

			if
				target.Density == phys.Density
				and target.Elasticity == phys.Elasticity
				and target.Friction == phys.Friction
				and target.ElasticityWeight == phys.ElasticityWeight
				and target.FrictionWeight == phys.FrictionWeight
				and (target :: any).AcousticAbsorption == (phys :: any).AcousticAbsorption
			then
				return `PhysicalProperties.new({convert(material)})`
			end
		end

		local args = {}

		table.insert(args, convert(target.Density))
		table.insert(args, convert(target.Friction))
		table.insert(args, convert(target.Elasticity))
		table.insert(args, convert(target.FrictionWeight))
		table.insert(args, convert(target.ElasticityWeight))
		table.insert(args, convert((target :: any).AcousticAbsorption))

		return `PhysicalProperties.new({table.concat(args, ", ")})`
	end,

	Random = function()
		return "Random.new()"
	end,

	Ray = function(target: Ray, convert)
		local directionEmpty = target.Direction.Magnitude == 0
		local originEmpty = (target.Origin.Magnitude == 0) and directionEmpty

		local args = {}

		if not originEmpty then
			table.insert(args, convert(target.Origin))
		end

		if not directionEmpty then
			table.insert(args, convert(target.Direction))
		end

		return `Ray.new({table.concat(args, ", ")})`
	end,

	RaycastParams = function(target: RaycastParams, convert)
		local base = RaycastParams.new()
		local properties = {
			{ "FilterDescendantsInstances", base.FilterDescendantsInstances },
			{ "FilterType", base.FilterType },
			{ "CollisionGroup", base.CollisionGroup },
			{ "RespectCanCollide", base.RespectCanCollide },
			{ "BruteForceAllSlow", base.BruteForceAllSlow },
			{ "IgnoreWater", base.IgnoreWater },
		} :: { { any } }

		local lines = {}
		table.insert(lines, "local params = RaycastParams.new()")

		for _, data in next, properties do
			local propertyName, propertyDefault = unpack(data)
			local current = (target :: any)[propertyName]
			if current == propertyDefault then
				continue
			end

			if typeof(current) == "table" and exports.isArray(current) then
				local isModified = false
				for _, v in next, current do
					if not table.find(propertyDefault, v) then
						isModified = true
					end
				end

				if not isModified then
					continue
				end
			end

			table.insert(lines, `params{exports.index(propertyName)} = {convert(current)}`)
		end

		table.insert(lines, "return params")

		base = nil :: any

		if #lines == 2 then
			return `RaycastParams.new()`
		else
			local body = table.concat(lines, "\n")
			return `(function()\n{exports.tab(body, 1)}\nend)()`
		end
	end,

	RaycastResult = blankHandler,
	RBXScriptConnection = blankHandler,
	RBXScriptSignal = blankHandler,

	Rect = function(target: Rect, convert)
		if target.Height == 0 and target.Width == 0 then
			return "Rect.new()"
		end

		local args = {}

		table.insert(args, convert(target.Min.X))
		table.insert(args, convert(target.Min.Y))
		table.insert(args, convert(target.Max.X))
		table.insert(args, convert(target.Max.Y))

		return `Rect.new({table.concat(args, ", ")})`
	end,

	Region3 = function(target: Region3, convert)
		local center = target.CFrame.Position
		local size = target.Size / 2

		local min = center - size
		local max = center + size

		return `Region3.new({convert(min)}, {convert(max)})`
	end,

	Region3int16 = function(target: Region3int16, convert)
		return `Region3int16.new({convert(target.Min)}, {convert(target.Max)})`
	end,

	RotationCurveKey = function(target: RotationCurveKey, convert)
		local args = {}

		table.insert(args, convert(target.Time))
		table.insert(args, convert(target.Value))
		table.insert(args, convert(target.Interpolation))

		return `RotationCurveKey.new({table.concat(args, ", ")})`
	end,

	Secret = blankHandler,
	SecurityCapabilities = function(target: SecurityCapabilities, convert)
		local args = {}

		for _, enum in next, capabilities.list(target) do
			table.insert(args, convert(enum))
		end

		return `SecurityCapabilities.new({table.concat(args, ", ")})`
	end,

	SharedTable = function(target: SharedTable, convert)
		local tb = {}
		for k, v in target do
			tb[k] = v
		end

		return `SharedTable.new({convert(tb)})`
	end,

	TweenInfo = function(target: TweenInfo, convert)
		local base = TweenInfo.new()

		local parseUntil = 0
		local properties = {
			{ "Time", base.Time },
			{ "EasingStyle", base.EasingStyle },
			{ "EasingDirection", base.EasingDirection },
			{ "RepeatCount", base.RepeatCount },
			{ "Reverses", base.Reverses },
			{ "DelayTime", base.DelayTime },
		} :: { { any } }

		for i, v in next, properties do
			local current = (target :: any)[v[1]]
			if current ~= v[2] then
				parseUntil = i
			end
		end

		local args = {}

		if parseUntil > 0 then
			for i = 1, parseUntil do
				table.insert(args, convert((target :: any)[properties[i][1]]))
			end
		end

		return `TweenInfo.new({table.concat(args, ", ")})`
	end,

	UDim = function(target: UDim, convert)
		return `UDim.new({convert(target.Scale)}, {convert(target.Offset)})`
	end,

	UDim2 = function(target: UDim2, convert)
		if exports.isUDim2Empty(target) then
			return `UDim2.new(0, 0)`
		end

		if target.X.Offset == 0 and target.Y.Offset == 0 then
			return `UDim2.fromScale({convert(target.X.Scale)}, {convert(target.Y.Scale)})`
		end

		if target.X.Scale == 0 and target.Y.Scale == 0 then
			return `UDim2.fromOffset({convert(target.X.Offset)}, {convert(target.Y.Offset)})`
		end

		local args = {}

		table.insert(args, convert(target.X.Scale))
		table.insert(args, convert(target.X.Offset))
		table.insert(args, convert(target.Y.Scale))
		table.insert(args, convert(target.Y.Offset))

		return `UDim2.new({table.concat(args, ", ")})`
	end,

	ValueCurveKey = function(target: ValueCurveKey, convert)
		local args = {}

		table.insert(args, convert(target.Time))
		table.insert(args, convert(target.Value))
		table.insert(args, convert(target.Interpolation))

		return `ValueCurveKey.new({table.concat(args, ", ")})`
	end,

	Vector2 = function(target: Vector2, convert)
		for _, v in
			next,
			{
				{ Vector2.zero, "Vector2.zero" },
				{ Vector2.one, "Vector2.one" },

				{ Vector2.yAxis, "Vector2.yAxis" },
				{ -Vector2.yAxis, "-Vector2.yAxis" },

				{ Vector2.xAxis, "Vector2.xAxis" },
				{ -Vector2.xAxis, "-Vector2.xAxis" },
			} :: { { any } }
		do
			if target == v[1] then
				return v[2]
			end
		end

		-- not really needed since they dont save enough char count
		-- if target.Y == 0 then
		-- 	return `Vector2.xAxis * {convert(target.X)}`
		-- elseif target.X == 0 then
		-- 	return `Vector2.yAxis * {convert(target.Y)}`
		-- end

		if target.X == target.Y then
			return `Vector2.one * {convert(target.X)}`
		end

		local args = {}
		for _, v in next, { "X", "Y" } do
			table.insert(args, convert((target :: any)[v]))
		end

		return `Vector2.new({table.concat(args, ", ")})`
	end,

	Vector2int16 = function(target: Vector2int16, convert)
		local args = {}
		for _, v in next, { "X", "Y" } do
			table.insert(args, convert((target :: any)[v]))
		end

		return `Vector2int16.new({table.concat(args, ", ")})`
	end,

	Vector3 = function(target: Vector3, convert)
		for _, v in
			next,
			{
				{ Vector3.zero, "Vector3.zero" },
				{ Vector3.one, "Vector3.one" },

				{ Vector3.yAxis, "Vector3.yAxis" },
				{ -Vector3.yAxis, "-Vector3.yAxis" },

				{ Vector3.zAxis, "Vector3.zAxis" },
				{ -Vector3.zAxis, "-Vector3.zAxis" },

				{ Vector3.xAxis, "Vector3.xAxis" },
				{ -Vector3.xAxis, "-Vector3.xAxis" },
			} :: { { any } }
		do
			if target == v[1] then
				return v[2]
			end
		end

		if target.Y == 0 and target.Z == 0 then
			return `Vector3.xAxis * {convert(target.X)}`
		elseif target.X == 0 and target.Z == 0 then
			return `Vector3.yAxis * {convert(target.Y)}`
		elseif target.X == 0 and target.Y == 0 then
			return `Vector3.zAxis * {convert(target.Z)}`
		end

		if target.X == target.Y and target.X == target.Z then
			return `Vector3.one * {convert(target.X)}`
		end

		local args = {}
		for _, v in next, { "X", "Y", "Z" } do
			table.insert(args, convert((target :: any)[v]))
		end

		return `Vector3.new({table.concat(args, ", ")})`
	end,

	Vector3int16 = function(target: Vector3int16, convert)
		local args = {}
		for _, v in next, { "X", "Y", "Z" } do
			table.insert(args, convert((target :: any)[v]))
		end

		return `Vector3int16.new({table.concat(args, ", ")})`
	end,
} :: {
	[string]: (target: any, convert: (t: any, ...any) -> string, ...any) -> string,
}

function exports.toString(target: any, ...: any): string
	local dataType = typeof(target)
	local handler = exports.types[dataType]

	if not handler then
		warn(`no handler for {dataType}`)
		return "nil"
	end

	return handler(target, exports.toString, ...)
end

return exports
