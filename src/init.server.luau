local serializer = require("@self/serializer")

local job = serializer.new()
job:parse(workspace.Baseplate)
job:start()
