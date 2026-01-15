local react = require(script.Parent.Parent.Parent.Parent.packages.react)
local builders = require(script.Parent.Parent.Parent.builders)

return function(props: any, valueName: string, property: any)
	local supported, setSupported = react.useState(false)

	react.useEffect(function()
		for k, v in next, builders.list do
			if v.id == props[valueName] then
				setSupported(v[property])
				break
			end
		end
	end, { props[valueName] })

	return supported, setSupported
end
