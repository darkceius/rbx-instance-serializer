local react = require(script.Parent.Parent.Parent.Parent.packages.react)
local tableUtil = require(script.Parent.Parent.Parent.Parent.packages.tableUtil)
local e = react.createElement

return function(props: { children: any, LayoutOrder: number, class: string?, props: any })
	return e(
		props.class or "Frame",
		tableUtil.Reconcile(props.props or {}, {
			LayoutOrder = props.LayoutOrder or 1,
			Size = UDim2.fromOffset(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
		}),
		tableUtil.Reconcile(props.children, {
			listLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
	)
end
