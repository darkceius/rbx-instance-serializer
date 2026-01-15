-- plugin.luau
-- @darkceius

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ScriptEditorService = game:GetService("ScriptEditorService")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local charm = require(script.Parent.Parent.packages.charm)
local react = require(script.Parent.Parent.packages.react)
local reactRoblox = require(script.Parent.Parent.packages.reactRoblox)
local builders = require(script.Parent.builders)
local app = require(script.components.app)

local serializer = require(script.Parent.serializer)
local logger = require(script.Parent.utils.logger)

local config = {
	builder = "vanilla",

	wrapChildren = true,
	useExports = true,
	parentRoots = false,
}

local function showSerialized(source: string, useExports: boolean)
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

local function serializeAction()
	--| Serializing
	logger.print("Serializing with following config", config)

	local targetBuilder
	for _, builder in next, builders.list do
		if builder.id == config.builder and builder.module then
			targetBuilder = builder.module
			break
		end
	end

	if not targetBuilder then
		targetBuilder = builders.vanilla
		logger.warn(`Could not find builder "{config.builder}"; using vanilla instead!`)
	end

	local job = serializer.new(targetBuilder)

	for k, v in next, config do
		job.builder.configs[k] = v
	end

	for _, v in next, Selection:Get() do
		local instance = job:add(v)
		instance._rawParent = v.Parent
	end

	local source = job:serialize()

	--| Creating src holder
	local recording = ChangeHistoryService:TryBeginRecording("SerializeButton1")
	if not recording then
		logger.warn("Failed to begin history recording!")
		return
	end

	local success, output = pcall(showSerialized, source, config.useExports)

	if success then
		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	else
		logger.warn("Failed to show serialized output", tostring(output))
		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Cancel)
	end
end

return function(plugin: Plugin?)
	if not plugin then
		return
	end

	local toolbar = plugin:CreateToolbar("Instance Serializer")

	--| Quick Serialize
	toolbar
		:CreateButton("Serialize", "Serialize the selected selection instances", "rbxassetid://13850024076").Click
		:Connect(serializeAction)

	--| Widget
	local widget = plugin:CreateDockWidgetPluginGuiAsync(
		"Instance Serializer",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 300, 300, 300, 300)
	)

	widget.Title = "Instance Serializer"
	widget.Name = widget.Title

	toolbar
		:CreateButton("Settings", "Toggle the instance serialization settings widget", "rbxassetid://13850087723").Click
		:Connect(function()
			widget.Enabled = not widget.Enabled
		end)

	reactRoblox.createRoot(widget):render(react.createElement(app, {
		plugin = plugin,
		config = charm.atom(config),

		serialize = serializeAction,
	}, {}))
end
