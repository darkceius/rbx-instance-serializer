-- capabilities.luau
-- @darkceius
--#selene: allow(undefined_variable)
-- ^ SecurityCapabilities hasn't been added to selene's globals yet

local exports = {}

local deprecatedEnums = {
	[Enum.SecurityCapability.Avatar] = true,
}

exports.baseScript = {
	Enum.SecurityCapability.RunClientScript,
	Enum.SecurityCapability.RunServerScript,
	Enum.SecurityCapability.AccessOutsideWrite,
	Enum.SecurityCapability.AssetRequire,
	Enum.SecurityCapability.LoadString,
	Enum.SecurityCapability.ScriptGlobals,
	Enum.SecurityCapability.CreateInstances,
	Enum.SecurityCapability.Basic,
	Enum.SecurityCapability.Audio,
	Enum.SecurityCapability.DataStore,
	Enum.SecurityCapability.Network,
	Enum.SecurityCapability.Physics,
	Enum.SecurityCapability.UI,
	Enum.SecurityCapability.CSG,
	Enum.SecurityCapability.Chat,
	Enum.SecurityCapability.Animation,
	Enum.SecurityCapability.Input,
	Enum.SecurityCapability.Environment,
	Enum.SecurityCapability.RemoteEvent,
	Enum.SecurityCapability.LegacySound,
	Enum.SecurityCapability.Players,
	Enum.SecurityCapability.CapabilityControl,
	Enum.SecurityCapability.Unassigned,
	Enum.SecurityCapability.AssetRead,
	Enum.SecurityCapability.AssetManagement,
	Enum.SecurityCapability.DynamicGeneration,
	Enum.SecurityCapability.PlatformAvatarEditing,
	Enum.SecurityCapability.AssetCreateUpdate,
	Enum.SecurityCapability.Capture,
	Enum.SecurityCapability.SensitiveInput,
	Enum.SecurityCapability.Monetization,
	Enum.SecurityCapability.LoadOwnedAsset,
	Enum.SecurityCapability.Social,
	Enum.SecurityCapability.ServerCommunication,
	Enum.SecurityCapability.Logging,
	Enum.SecurityCapability.PromptExternalPurchase,
	Enum.SecurityCapability.Groups,
	Enum.SecurityCapability.Teleport,
	Enum.SecurityCapability.Consequences,
	Enum.SecurityCapability.Material,
	Enum.SecurityCapability.AvatarBehavior,
	Enum.SecurityCapability.AvatarAppearance,
	Enum.SecurityCapability.LoadUnownedAsset,
}

function exports.list(ref: SecurityCapabilities?): { Enum.SecurityCapability }
	local securityCapability = ref or SecurityCapabilities.fromCurrent()
	local capabilityArray = {}

	for _, v in next, Enum.SecurityCapability:GetEnumItems() do
		if securityCapability:Contains(v) and not deprecatedEnums[v] then
			table.insert(capabilityArray, v)
		end
	end

	return capabilityArray
end

function exports.check(target: SecurityCapabilities, current: SecurityCapabilities)
	return current:Contains(unpack(exports.list(target)))
end

function exports.create()
	return SecurityCapabilities.new(unpack(exports.baseScript))
end

return exports
