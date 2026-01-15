local react = require(script.Parent.Parent.Parent.Parent.packages.react)
local builders = require(script.Parent.Parent.Parent.builders)

local function useBuilders()
	local buildItems, setBuildItems = react.useState({} :: any)

	react.useEffect(function()
		local items = {}

		for _, data in next, builders.list do
			table.insert(items, {
				Id = data.id,
				Text = data.name,

				-- TODO figure out why Icon causes errors
			})
		end

		setBuildItems(items)
	end, {})

	return buildItems
end

return useBuilders
