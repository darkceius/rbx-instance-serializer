local RunService = game:GetService("RunService")
local serializer = require("@self/serializer")

if RunService:IsStudio() then
	if RunService:IsRunMode() then
		require("@self/test")
	end

	if plugin then
		require("@self/plugin")(plugin)
	end
end

return serializer
