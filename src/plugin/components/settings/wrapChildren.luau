local comps = require(script.Parent.Parent.Parent.Parent.Parent.packages.comps)
local react = require(script.Parent.Parent.Parent.Parent.Parent.packages.react)
local useSetting = require(script.Parent.Parent.Parent.hooks.useSetting)
local useSupported = require(script.Parent.Parent.Parent.hooks.useSupported)
local typedefs = require(script.Parent.Parent.typedefs)
local e = react.createElement

local settingName = "wrapChildren"

return function(props: typedefs.props)
	local value, setValue = useSetting({
		plugin = props.plugin,
		config = props.config,

		name = settingName,
		default = true,
	})

	if not useSupported(props, "selectedBuilder", settingName) then
		return
	end

	return e(comps.Checkbox, {
		LayoutOrder = props.LayoutOrder,
		Label = "Wrap children in blocks",

		Value = value,
		OnChanged = function()
			return setValue(not value)
		end,
	})
end
