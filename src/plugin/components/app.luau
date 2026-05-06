-- app.luau
-- @darkceius

local autoSelect = require("./settings/autoSelect")
local wrapChildren = require("./settings/wrapChildren")
local autoOpen = require("./settings/autoOpen")
local comps = require("../../../packages/comps")
local createLayoutOrder = require("../helpers/createLayoutOrder")
local escapeStringNewline = require("./settings/escapeStringNewline")
local holder = require("./holder")
local parentRoots = require("./settings/parentRoots")
local react = require("../../../packages/react")
local roundNumbers = require("./settings/roundNumbers")
local serializeAttributes = require("./settings/serializeAttributes")
local serializeTags = require("./settings/serializeTags")
local tableUtil = require("../../../packages/tableUtil")
local useAutoLayoutOrder = require("./settings/useAutoLayoutOrder")
local useExports = require("./settings/useExports")
local useNameProperty = require("./settings/useNameProperty")
local useSetting = require("../hooks/useSetting")
local useWorldProperties = require("./settings/useWorldProperties")
local builder = require("./settings/builder")
local e = react.createElement

local function uiRoot(props: { plugin: Plugin, config: any, serialize: any })
	local plugin = props.plugin
	local config = props.config

	--| Hooks
	local propsUsed, setPropsUsed = react.useState(false)
	local selectedBuilder, setSelectedBuilder = useSetting({
		plugin = plugin,
		config = config,

		name = "builder",
		default = "vanilla",
	})

	react.useEffect(function()
		setPropsUsed(false)
	end, { selectedBuilder })

	--| Components
	local layoutOrder = createLayoutOrder()

	local compShared = {
		plugin = plugin,
		config = config,

		setPropsUsed = not propsUsed and setPropsUsed,

		selectedBuilder = selectedBuilder,
		setSelectedBuilder = setSelectedBuilder,
	}

	local children = {
		listLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5),
		}),

		padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
		}),

		builder = e(
			builder,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		useExports = e(
			useExports,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		parentRoots = e(
			parentRoots,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		wrapChildren = e(
			wrapChildren,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		autoSelect = e(
			autoSelect,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		autoOpen = e(
			autoOpen,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		--| Properties
		label = propsUsed and e(comps.Label, {
			LayoutOrder = layoutOrder(),

			Text = "Properties",
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 14),
		}),

		serializeTags = e(
			serializeTags,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		serializeAttributes = e(
			serializeAttributes,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		useAutoLayoutOrder = e(
			useAutoLayoutOrder,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		useWorldProperties = e(
			useWorldProperties,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		useNameProperty = e(
			useNameProperty,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		roundNumbers = e(
			roundNumbers,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),

		escapeStringNewline = e(
			escapeStringNewline,
			tableUtil.Reconcile({
				LayoutOrder = layoutOrder(),
			}, compShared)
		),
	}

	return e(comps.Background, {}, {
		relative = e(holder, {
			class = "ScrollingFrame",
			props = {
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromOffset(0, 0),
				Size = UDim2.fromScale(1, 1),
				AutomaticSize = Enum.AutomaticSize.None,
				ScrollBarImageTransparency = 1,
			},
		}, children),

		absolute = e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			listLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
			}),

			padding = e("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
			}),

			serialize = e(comps.MainButton, {
				LayoutOrder = layoutOrder(),

				Text = "Serialize",
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 1),

				OnActivated = function()
					task.spawn(props.serialize)
				end,
			}),
		}),
	})
end

return uiRoot
