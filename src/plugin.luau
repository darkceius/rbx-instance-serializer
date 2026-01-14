local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ScriptEditorService = game:GetService("ScriptEditorService")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local logger = require("./utils/logger")
local serializer = require("./serializer")

local function appendSerialized(source: string, useExports: boolean)
	local holderScript = Instance.new(useExports and "ModuleScript" or "Script")
	holderScript.Name = "Output"
	holderScript.Parent = ServerStorage

	ScriptEditorService:UpdateSourceAsync(holderScript :: any, function()
		return source
	end)

	Selection:Set({ holderScript })

	ScriptEditorService:OpenScriptDocumentAsync(holderScript :: any)

	return holderScript
end

return function(plugin: Plugin)
	if not plugin then
		return
	end

	local toolbar = plugin:CreateToolbar("Instance Serializer")
	local button =
		toolbar:CreateButton("Serialize", "Serialize the selected selection instances", "rbxassetid://13850024076")

	button.Click:Connect(function()
		local useExports = true

		--| Serializing
		local job = serializer.new(require("./builders/vanilla"))
		job.builder.configs.exports = useExports

		for _, v in next, Selection:Get() do
			job:add(v)
		end

		local source = job:serialize()

		--| Creating src holder
		local recording = ChangeHistoryService:TryBeginRecording("SerializeButton1")
		if not recording then
			logger.warn("Failed to begin history recording!")
			return
		end

		local success, output = pcall(appendSerialized, source, useExports)

		if success then
			ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		else
			logger.warn("Failed to show serialized output", tostring(output))
			ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Cancel)
		end
	end)
end
