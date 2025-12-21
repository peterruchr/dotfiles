return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")

			vim.keymap.set("n", "<F5>", dap.restart, { desc = "Debug: Restart" })
			vim.keymap.set("n", "<F9>", dap.continue, { desc = "Debug: Continue" })
			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step over" })
			vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step out" })
			vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dapui = require("dapui")
			dapui.setup()

			local dap = require("dap")
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
			dap.listeners.after.event_output.dapui_config = function(_, body)
				if body.category == "console" then
					dapui.eval(body.output)
				end
			end
		end,
	},

	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		config = function()
			require("mason-nvim-dap").setup({
				ensure_installed = {
					"coreclr",
				},
				automatic_installation = true,
				-- Default DAP configurations for none specific.
				handlers = {
					function(config)
						require("mason-nvim-dap").default_setup(config)
					end,
				},
				-- DOTNET setup
				coreclr = function(config)
					config.adapters = {
						type = "executable",
						command = vim.fn.exepath("netcoredbg"),
						args = { "--interpreter=vscode" },
					}

					config.configurations = {
						{
							type = "coreclr",
							name = "Launch - NET core",
							request = "launch",
							program = function()
								local project_path = vim.fs.root(0, function(name)
									return name:match("%.csproj$") ~= nil
								end)

								if not project_path then
									return vim.notify("Couldn't find the csproj path")
								end

								return require("dap.utils").pick_file({
									filter = string.format("Debug/.*/%s", vim.fn.fnamemodify(project_path, ":t:r")),
									path = string.format("%s/bin", project_path),
								})
							end,
						},
						{
							type = "coreclr",
							name = "Attach - NET core",
							request = "attach",
							processId = function()
								return require("dap.utils").pick_process({
									filter = function(proc)
										---@diagnostic disable-next-line: return-type-mismatch
										return proc.name:match(".*/Debug/.*")
											and not proc.name:find("vstest.console.dll")
									end,
								})
							end,
						},
					}
					require("mason-nvim-dap").default_setup(config)
				end,
			})
		end,
	},
}
