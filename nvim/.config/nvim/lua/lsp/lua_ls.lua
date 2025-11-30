local base = require("lsp.base")

-- Define the server config
vim.lsp.config("lua_ls", {
	on_attach = base.on_attach,
	capabilities = base.capabilities,
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace", -- improves snippet behavior
			},
			diagnostics = {
				globals = { "vim" }, -- prevents "undefined global" warnings for Neovim API
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true), -- makes Neovim runtime API known
				checkThirdParty = false, -- optional, avoids prompts
			},
		},
	},
})

-- Enable the server
vim.lsp.enable("lua_ls")
