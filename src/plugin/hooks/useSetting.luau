local react = require(script.Parent.Parent.Parent.Parent.packages.react)

local function useSetting<T>(data: {
	plugin: Plugin,
	config: () -> any,
	name: string,
	default: T,
})
	local default = data.default
	local plugin = data.plugin
	local name = data.name

	assert(typeof(default) ~= "nil", "default cannot be of type nil!")

	local value: T?, setValue = react.useState(nil :: T?)

	react.useEffect(function()
		local savedValue = plugin:GetSetting(name)

		if savedValue == nil then
			setValue(default)
		else
			setValue(savedValue)
		end
	end, {})

	react.useEffect(function()
		plugin:SetSetting(name, value)

		local config = data.config()
		config[data.name] = value
	end, { value })

	return value, setValue
end

return useSetting
