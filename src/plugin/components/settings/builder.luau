local comps = require("../../../../packages/comps")
local createLayoutOrder = require("../../helpers/createLayoutOrder")
local holder = require("../holder")
local react = require("../../../../packages/react")
local typedefs = require("../typedefs")
local useBuilders = require("../../hooks/useBuilders")
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
