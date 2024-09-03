local function happy_stuff()
  return [[幸 🌊]]
end

local lualine_conf = {
  options = {
    icons_enabled = true,
    theme = 'kanagawa',
    component_separators = { left = '\u{e0b9}', right = '\u{e0bf}' },
    section_separators = { left = '\u{e0b8}', right = '\u{e0be}' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = { { 'mode', separator = { left = '\u{e0b6}', right = '\u{e0b8}' }, right_padding = 1 } },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype', happy_stuff },
    lualine_y = { 'progress' },
    lualine_z = { 'location', { 'datetime', style = '%H:%M:%S', separator = { right = '\u{e0b4}' }, left_padding = 1 } },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = { 'trouble' },
}

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local trouble = require 'trouble'
    local symbols = trouble.statusline {
      mode = 'lsp_document_symbols',
      groups = {},
      title = false,
      filter = { range = true },
      format = '{kind_icon}{symbol.name:Normal}',
    }
    table.insert(lualine_conf.sections.lualine_c, {
      symbols.get,
      cond = symbols.has,
    })
    require('lualine').setup(lualine_conf)
  end,
}
