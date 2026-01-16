-- app.luau
-- @darkceius

local comps = require(script.Parent.Parent.Parent.Parent.packages.comps)
local react = require(script.Parent.Parent.Parent.Parent.packages.react)
local tableUtil = require(script.Parent.Parent.Parent.Parent.packages.tableUtil)
local createLayoutOrder = require(script.Parent.Parent.helpers.createLayoutOrder)
local useSetting = require(script.Parent.Parent.hooks.useSetting)
local holder = require(script.Parent.holder)
local builder = require(script.Parent.settings.builder)
local escapeStringNewline = require(script.Parent.settings.escapeStringNewline)
local parentRoots = require(script.Parent.settings.parentRoots)
local roundNumbers = require(script.Parent.settings.roundNumbers)
local useExports = require(script.Parent.settings.useExports)
local useNameProperty = require(script.Parent.settings.useNameProperty)
local useWorldProperties = require(script.Parent.settings.useWorldProperties)
local wrapChildren = require(script.Parent.settings.wrapChildren)
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

		--| Properties
		label = propsUsed and e(comps.Label, {
			LayoutOrder = layoutOrder(),

			Text = "Properties",
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 14),
		}),

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
				CanvasSize = UDim2.new(0, 0),
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
