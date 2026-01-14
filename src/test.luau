local serializer = require("@self/serializer")

local job = serializer.new()

job:add(workspace.Baseplate)
warn(job:serialize())

return nil
