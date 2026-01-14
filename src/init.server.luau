-- test script
local serializer = require("@self/serializer")

local job = serializer.new()
job:parse(workspace.KeycardVM, false)

warn(job:start())
