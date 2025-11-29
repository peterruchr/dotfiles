return {
  'mason-org/mason.nvim',
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  'mason-org/mason-lspconfig.nvim',
  config = function()
    require('mason').setup()
    require('mason-lspconfig').setup({
      ensure_installed = {'lua-ls'},
      automatic_installation = true,
    })
    requre('mason-tool-installer').setup({
      ensure_installed = {'stylua'},
      automatic_installation = true,
    })

  end
}
