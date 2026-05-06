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

		name = "serializeTags",
		default = true,
	})

	if not useSupported(props, "selectedBuilder", "serializeTags") then
		return
	end

	if props.setPropsUsed then
		props.setPropsUsed(true)
	end

	return e(comps.Checkbox, {
		LayoutOrder = props.LayoutOrder,
		Label = "Include Tags",

		Value = value,
		OnChanged = function()
			return setValue(not value)
		end,
	})
end
