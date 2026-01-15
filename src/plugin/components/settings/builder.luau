local comps = require(script.Parent.Parent.Parent.Parent.Parent.packages.comps)
local react = require(script.Parent.Parent.Parent.Parent.Parent.packages.react)
local holder = require(script.Parent.Parent.Parent.components.holder)
local createLayoutOrder = require(script.Parent.Parent.Parent.helpers.createLayoutOrder)
local useBuilders = require(script.Parent.Parent.Parent.hooks.useBuilders)
local typedefs = require(script.Parent.Parent.typedefs)
local e = react.createElement

return function(props: typedefs.props)
	local layoutOrder = createLayoutOrder()
	local builders = useBuilders()

	local selectedBuilder, setSelectedBuilder = props.selectedBuilder, props.setSelectedBuilder

	return e(holder, {
		LayoutOrder = props.LayoutOrder,
	}, {

		label = e(comps.Label, {
			LayoutOrder = layoutOrder(),

			Text = "Target Environment",
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 14),
		}),

		dropdown = e(comps.Dropdown, {
			LayoutOrder = layoutOrder(),

			Items = builders,
			SelectedItem = selectedBuilder,
			OnItemSelected = setSelectedBuilder,

			DefaultText = "Select a builder",
		}),
	})
end
