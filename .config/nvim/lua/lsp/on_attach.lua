local buf_map = require('utils').buf_map
local buf_option = require('utils').buf_option

local function on_attach(client)
  buf_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = {
    noremap = true,
    silent = true
  }

  buf_map('i', '<Tab>', 'pumvisible() ? "<C-n>" : "<Tab>"', { expr = true, noremap = true })
  buf_map('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<S-Tab>"', { expr = true, noremap = true })

  -- if client.resolved_capabilities.document_formatting then
  --   vim.api.nvim_command [[augroup Format]]
  --   vim.api.nvim_command [[autocmd! * <buffer>]]
  --   vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)]]
  --   vim.api.nvim_command [[augroup END]]
  -- end
end

return on_attach
