local app = require("../components/app")
local charm = require("../../../packages/charm")
local react = require("../../../packages/react")
local reactRoblox = require("../../../packages/reactRoblox")

return {
	react = react,
	reactRoblox = reactRoblox,

	story = function()
		return react.createElement(app, {
			plugin = {
				GetSetting = function()
					return
				end,

				SetSetting = function()
					return
				end,
			},

			config = charm.atom({}),

			widget = { Enabled = true },
		})
	end,
}
