return {
  'rust-sailfish/sailfish',
  event = 'VeryLazy',
  dev = true,
  dir = '~/local-lazy-plugins/sailfish/syntax/vim',
  -- -- event = { 'BufRead', 'BufNewFile' }, -- Changed from ft to ensure it loads
  -- -- event = 'VeryLazy',
  -- dir = '~/.local/share/nvim/lazy/sailfish/syntax/vim',
  -- config = function()
  --     -- Add the runtime path
  --
  --     -- Explicitly set up file detection
  --     vim.filetype.add({
  --       extension = {
  --         stpl = "sailfish"
  --       }
  --     })
  --
  --     -- Force reload syntax
  --     vim.cmd([[
  --       au BufRead,BufNewFile *.stpl set filetype=sailfish
  --       syntax enable
  --     ]])
  --   end,
}
