local builders = require("../../builders")
local react = require("../../../packages/react")

return function(props: any, valueName: string, property: any)
	local supported, setSupported = react.useState(false)

	react.useEffect(function()
		for _, v in next, builders.list do
			if v.id == props[valueName] and v.supports then
				setSupported(v.supports[property] == true)
				break
			end
		end
	end, { props[valueName] })

	return supported, setSupported
end
