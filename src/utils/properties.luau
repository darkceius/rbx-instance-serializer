-- properties.luau
-- @darkceius

local ReflectionService = game:GetService("ReflectionService")
local capabilities = require(script.Parent.capabilities)
local exports = {}

exports.excludedPropertiesFor = {
	CFrame = {
		Rotation = true,
		Position = true,
		Orientation = true,
	},

	Parent = { Parent = true },
	Image = { ImageContent = true },
	FontFace = { Font = true },

	Color = { BrickColor = true },
	BackgroundColor3 = { BackgroundColor = true },
	TextColor3 = { TextColor = true },
	BackgroundTransparency = { Transparency = true },
	TextTransparency = { Transparency = true },
	TextStrokeTransparency = { Transparency = true },

	TextureID = { TextureContent = true },
	TextureId = { TextureContent = true },

	Texture = {
		ColorMapContent = true,
		TextureContent = true,
		ColorMap = true,
	},
}

exports["nil"] = newproxy()
exports.cache = {} :: { [string]: any }
exports.cacheClearThread = task.spawn(function()
	while true do
		task.wait(60 * 3)
		table.clear(exports.cache)
	end
end)

function exports.isNil(value: any)
	return value == exports["nil"]
end

function exports.convert(value: any)
	if exports.isNil(value) then
		return nil
	end

	return value
end

function exports.getProperties(className: string)
	if exports.cache[className] then
		return exports.cache[className]
	end

	local properties = {}
	properties.defaults = {} :: { [string]: any }
	properties.valid = {} :: { string }
	properties.prohibited = false
	properties.reason = nil :: string?

	--| Current security props
	local securityContext = SecurityCapabilities.new(unpack(capabilities.baseScript))
	local targetProperties = {}

	for _, prop in next, ReflectionService:GetPropertiesOfClass(className, { Security = securityContext }) do
		local permits = prop.Permits
		if not permits then
			continue
		end

		if permits.Read == nil or permits.Write == nil then
			continue
		end

		--| Ignoring deprecated
		if prop.Display and prop.Display.DeprecationMessage then
			continue
		end

		--| Extra permit checks
		if not capabilities.check(permits.Read, securityContext) then
			continue
		end

		if not capabilities.check(permits.Write, securityContext) then
			continue
		end

		table.insert(targetProperties, prop.Name)
	end

	for prop, ignored in next, exports.excludedPropertiesFor do
		if table.find(targetProperties, prop) then
			for i = #targetProperties, 1, -1 do
				local v = targetProperties[i]
				if ignored[v] then
					table.remove(targetProperties, i)
				end
			end
		end
	end

	local success, class = pcall(Instance.new, className)
	if success and typeof(class) == "Instance" then
		for _, propertyName in next, targetProperties do
			local defaultValue = (class :: any)[propertyName];
			(class :: any)[propertyName] = defaultValue -- should error if invalid

			if defaultValue == nil then
				defaultValue = exports["nil"]
			end

			properties.defaults[propertyName] = defaultValue
			table.insert(properties.valid, propertyName)
		end

		class:Destroy()
	else
		properties.reason = tostring(class)
		properties.prohibited = true
	end

	exports.cache[className] = properties
	return properties
end

function exports.getChangedProperties(instance: Instance)
	local properties = exports.getProperties(instance.ClassName)

	local changed = {}
	for property, default in next, properties.defaults do
		if (instance :: any)[property] ~= exports.convert(default) then
			table.insert(changed, property)
		end
	end

	return changed
end

return exports
