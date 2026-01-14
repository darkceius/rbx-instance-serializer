-- capabilities.luau
-- @darkceius

local exports = {}

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
	Enum.SecurityCapability.Avatar,
	Enum.SecurityCapability.Input,
	Enum.SecurityCapability.Environment,
	Enum.SecurityCapability.RemoteEvent,
	Enum.SecurityCapability.LegacySound,
	Enum.SecurityCapability.Players,
	Enum.SecurityCapability.CapabilityControl,
	Enum.SecurityCapability.Unassigned,
}

function exports.list(ref: SecurityCapabilities?): { Enum.SecurityCapability }
	local securityCapability = ref or SecurityCapabilities.fromCurrent()
	local capabilityArray = {}

	for _, v in next, Enum.SecurityCapability:GetEnumItems() do
		if securityCapability:Contains(v) then
			table.insert(capabilityArray, v)
		end
	end

	return capabilityArray
end

function exports.check(target: SecurityCapabilities, current: SecurityCapabilities)
	return current:Contains(unpack(exports.list(target)))
end

return exports
