local charm = require(script.Parent.Parent.Parent.Parent.packages.charm)
local react = require(script.Parent.Parent.Parent.Parent.packages.react)
local reactRoblox = require(script.Parent.Parent.Parent.Parent.packages.reactRoblox)
local app = require(script.Parent.Parent.components.app)

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
