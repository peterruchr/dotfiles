local M = {}

-- Shared on_attach for all LSPs
M.on_attach = function(client, bufnr)
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  -- Keymaps
  map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('gra', vim.lsp.buf.code_action, '[C]ode [A]ction', {'n','x'})
  map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
  map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
  map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

  -- Optional: Inlay hints toggle
  if client.supports_method and client.supports_method('textDocument/inlayHint') then
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
    end, '[T]oggle Inlay [H]ints')
  end
end

-- Shared capabilities (for blink.cmp, etc.)
M.capabilities = require('blink.cmp').get_lsp_capabilities()

return M
