return {
  'epwalsh/obsidian.nvim',
  --  version = '*', -- recommended, use latest release instead of latest commit
  lazy = false,
  ft = 'markdown',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    'nvim-lua/plenary.nvim',

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    daily_notes = {
      folder = 'Daily',
      date_format = '%Y/%m-%B/%Y-%m-%d-%A',
      template = 'daily.md',
    },
    workspaces = {
      -- {
      --   name = 'work',
      --   path = '~/OneDrive - shure/obsidian/work/',
      -- },
      {
        name = 'personal',
        path = '~/obsidian/personal/',
      },
    },
    attachments = {
      img_folder = 'Attachments',
    },
    templates = {
      folder = 'templates',
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
    },
    -- see below for full list of options 👇
  },
}
