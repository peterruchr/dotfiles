return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")

			vim.keymap.set("n", "<F1>", dap.restart, { desc = "Debug: Restart" })
			vim.keymap.set("n", "<F2>", dap.continue, { desc = "Debug: Continue" })
			vim.keymap.set("n", "<F3>", dap.step_over, { desc = "Debug: Step over" })
			vim.keymap.set("n", "<F4>", dap.step_into, { desc = "Debug: Step into" })
			vim.keymap.set("n", "<F5>", dap.step_out, { desc = "Debug: Step out" })
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
			vim.keymap.set("n", "<leader>dt", function()
				require("dap").terminate()
				require("dapui").close()
			end)

			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Error", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "→", texthl = "Error", linehl = "DiffAdd", numhl = "" })

			dap.adapters.coreclr = {
				type = "executable",
				command = vim.fn.exepath("netcoredbg") or vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
				args = { "--interpreter=vscode" },
			}

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch",
					request = "launch",
					program = function()
						local project_path = vim.fs.root(0, function(name)
							return name:match("%.csproj$") ~= nil
						end)

						if not project_path then
							return vim.notify("Couldn't find the csproj path")
						end

						vim.fn.system("dotnet build " .. project_path)

						return require("dap.utils").pick_file({
							filter = string.format("Debug/.*/%s", vim.fn.fnamemodify(project_path, ":t:r")),
							path = string.format("%s/bin", project_path),
						})
					end,
				},
				{
					type = "coreclr",
					name = "Attach to process",
					request = "attach",
					processId = function()
						return require("dap.utils").pick_process({
							filter = function(p)
								return p.name:match(".*/Debug/.*") and not p.name:find("vstest.console.dll")
							end,
						})
					end,
				},
			}
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
			dap.listeners.after.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.after.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.after.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.after.event_exited.dapui_config = function()
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
			})
		end,
	},
}
