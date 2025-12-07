local base = require("lsp.base")

vim.lsp.config("roslyn", {
	on_attach = base.on_attach,
	capabilities = base.capabilities,
})

vim.lsp.enable("roslyn")
