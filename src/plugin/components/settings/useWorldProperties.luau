local comps = require("../../../../packages/comps")
local react = require("../../../../packages/react")
local typedefs = require("../typedefs")
local useSetting = require("../../hooks/useSetting")
local useSupported = require("../../hooks/useSupported")
local e = react.createElement

return function(props: typedefs.props)
	local value, setValue = useSetting({
		plugin = props.plugin,
		config = props.config,

		name = "useWorldProperties",
		default = false,
	})

	if not useSupported(props, "selectedBuilder", "useProperties") then
		return
	end

	if props.setPropsUsed then
		props.setPropsUsed(true)
	end

	return e(comps.Checkbox, {
		LayoutOrder = props.LayoutOrder,
		Label = "Include `World` properties",

		Value = value,
		OnChanged = function()
			return setValue(not value)
		end,
	})
end
