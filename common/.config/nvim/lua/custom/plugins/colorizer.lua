return {
  'norcalli/nvim-colorizer.lua',
  event = 'VeryLazy',
  config = function()
    -- setup step
    require('colorizer').setup {
      'css',
      'javascript',
      'typescript',
      html = {
        mode = 'foreground',
      },
    }
  end,
}
