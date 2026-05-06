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

		name = "parentRoots",
		default = false,
	})

	if not useSupported(props, "selectedBuilder", "parentRoots") then
		return
	end

	return e(comps.Checkbox, {
		LayoutOrder = props.LayoutOrder,
		Label = "Parent root instances",

		Value = value,
		OnChanged = function()
			return setValue(not value)
		end,
	})
end
