local comps = require(script.Parent.Parent.Parent.Parent.Parent.packages.comps)
local react = require(script.Parent.Parent.Parent.Parent.Parent.packages.react)
local useSetting = require(script.Parent.Parent.Parent.hooks.useSetting)
local typedefs = require(script.Parent.Parent.typedefs)
local e = react.createElement

return function(props: typedefs.props)
	local value, setValue = useSetting({
		plugin = props.plugin,
		config = props.config,

		name = "parentRoots",
		default = false,
	})

	return e(comps.Checkbox, {
		LayoutOrder = props.LayoutOrder,
		Label = "Parent root instances",

		Value = value,
		OnChanged = function()
			return setValue(not value)
		end,
	})
end
