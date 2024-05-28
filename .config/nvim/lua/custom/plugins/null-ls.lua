return {
  'nvimtools/none-ls.nvim',
  ft = { 'python' },
  opts = function()
    local bi = require 'null-ls.builtins'
    return {
      sources = {
        bi.diagnostics.mypy,
        bi.diagnostics.ruff,
      },
    }
  end,
}
