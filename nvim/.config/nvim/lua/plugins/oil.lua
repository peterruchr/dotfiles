return {
	"stevearc/oil.nvim",
	opts = {},
	-- Optional dependencies
	dependencies = { { "nvim-mini/mini.icons", opts = {} } },
	-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
	config = function()
		local oil = require("oil")
		oil.setup({})
		vim.keymap.set("n", "<leader>o", function()
			local path = vim.fn.expand("%:p:h") -- % = current buffer path, p = absolute path, h = closest directory
			oil.open(path)
		end, { desc = "Toggle Oil browser windows" })
	end,
}
