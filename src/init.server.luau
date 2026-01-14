local RunService = game:GetService("RunService")
local serializer = require("@self/serializer")

if RunService:IsStudio() then
	if RunService:GetAttribute("TEST_SERIALIZER") then
		require("@self/test")
	end

	require("@self/plugin")(plugin)
end

return serializer
