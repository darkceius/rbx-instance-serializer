local vanilla = require(script.vanilla)

return {
	vanilla = vanilla,
	list = {
		{
			id = "vanilla",
			module = vanilla :: typeof(vanilla)?,

			name = "Vanilla",
			supportsWrapChildren = true,
		},

		{
			id = "react",
			module = nil,

			name = "React",
			supportsWrapChildren = false,
		},
	},
}
