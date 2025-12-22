return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nsidorenco/neotest-vstest",
		},
		config = function()
			require("neotest").setup({
				-- Setup adapters
				adapters = {
					require("neotest-vstest")({
						dap_settings = {
							type = "coreclr",
							name = "Attach",
						},
					}),
				},
				icons = {
					running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
				},
				summary = {
					mappings = {
						jumpto = "gd",
					},
				},
			})

			-- Setup keybindings
			vim.keymap.set("n", "<leader>ts", function()
				require("neotest").summary.toggle()
			end, { desc = "Test: Toggle summary" })

			vim.keymap.set("n", "<leader>to", function()
				require("neotest").output_panel.toggle()
			end, { desc = "Test: Toggle output panel" })

			vim.keymap.set("n", "<leader>ta", function()
				require("neotest").run.run({ suite = true })
			end, { desc = "Test: Run suite" })

			vim.keymap.set("n", "<leader>tr", function()
				require("neotest").run.run()
			end, { desc = "Test: Running nearest test" })

			vim.keymap.set("n", "<leader>tf", function()
				require("neotest").run.run(vim.fn.expand("%"))
			end, { desc = "Test: Run test file" })

			vim.keymap.set("n", "<leader>td", function()
				require("neotest").run.run({
					strategy = "dap",
					suite = false,
				})
			end, { desc = "Test: Debug nearest test" })
		end,
	},
}
