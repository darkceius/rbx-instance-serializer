-- add testEZ tests for every datatype.toString() handler

local types = require(script.Parent.builders.types)
local serializer = require(script.Parent.serializer)
local job = serializer.new(types)

for _, v in next, workspace:GetChildren() do
	if v:HasTag("TestSerialize") then
		job:add(v)
	end
end

warn(job:serialize())

return nil
