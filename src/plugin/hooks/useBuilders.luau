local builders = require("../../builders")
local react = require("../../../packages/react")

local function useBuilders()
	local buildItems, setBuildItems = react.useState({} :: any)

	react.useEffect(function()
		local items = {}

		for _, data in next, builders.list do
			table.insert(items, {
				Id = data.id,
				Text = data.name,
			})
		end

		setBuildItems(items)
	end, {})

	return buildItems
end

return useBuilders
