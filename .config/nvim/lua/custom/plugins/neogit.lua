return {
  'NeogitOrg/neogit',
  opts = {
    integrations = {
      telescope = true,
      diffview = true,
      fzf_lua = false,
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed, not both.
    'nvim-telescope/telescope.nvim', -- optional
  },
  config = function(_, opts)
    require('neogit').setup(opts)
  end,
}
