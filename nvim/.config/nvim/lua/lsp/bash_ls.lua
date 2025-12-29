local base = require("lsp.base")

vim.lsp.config("bashls", {
	on_attach = base.on_attach,
	capabilities = base.capabilities,
	filetypes = { "bash", "sh", "zsh", "zshrc" },
})

vim.lsp.enable("bashls")
