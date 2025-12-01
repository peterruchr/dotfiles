local base = require("lsp.base")

vim.lsp.config("csharp_ls", {
	on_attach = base.on_attach,
	capabilities = base.capabilities,
})

vim.lsp.enable("csharp_ls")
