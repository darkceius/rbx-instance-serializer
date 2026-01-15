local function createLayoutOrder()
	local layoutOrder = 0

	return function()
		layoutOrder += 1

		return layoutOrder
	end
end

return createLayoutOrder
