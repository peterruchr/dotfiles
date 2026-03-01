return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		input = { enabled = true },
		statuscolumn = { enabled = true },
		notifier = { enabled = true },
		scroll = { enabled = true },
		indent = {
			enabled = true,
			indent = { enabled = false },
			scope = { enabled = true },
			animate = { enabled = false },
		},
	},
}
