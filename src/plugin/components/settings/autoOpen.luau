local comps = require("../../../../packages/comps")
local react = require("../../../../packages/react")
local typedefs = require("../typedefs")
local useSetting = require("../../hooks/useSetting")
local e = react.createElement

return function(props: typedefs.props)
	local value, setValue = useSetting({
		plugin = props.plugin,
		config = props.config,

		name = "autoOpen",
		default = true,
	})

	return e(comps.Checkbox, {
		LayoutOrder = props.LayoutOrder,
		Label = "Auto open serialized output",

		Value = value,
		OnChanged = function()
			return setValue(not value)
		end,
	})
end
