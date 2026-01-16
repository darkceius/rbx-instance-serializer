local list = {}

for _, v in next, script:GetChildren() do
	if v:IsA("ModuleScript") then
		local builder = (require)(v)
		builder.module = builder
		table.insert(list, builder)
	end
end

return {
	vanilla = require(script.vanilla),
	list = list :: {
		{
			id: string,
			name: string,

			module: any,
			supports: { [string]: boolean? },
		}
	},
}
