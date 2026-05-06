local comps = require("../../../../packages/comps")
local react = require("../../../../packages/react")
local typedefs = require("../typedefs")
local useSetting = require("../../hooks/useSetting")
local useSupported = require("../../hooks/useSupported")
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
