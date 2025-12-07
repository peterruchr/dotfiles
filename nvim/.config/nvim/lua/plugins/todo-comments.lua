return {
	"folke/todo-comments.nvim",
	event = "VimEnter",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("todo-comments").setup({
			signs = false,
		})

		vim.keymap.set("n", "<leader>st", "<cmd>TodoTelescope<CR>", { desc = "Open TODO comments Telescope" })
	end,
}
