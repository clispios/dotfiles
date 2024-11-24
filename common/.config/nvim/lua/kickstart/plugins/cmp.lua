return {
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'rafamadriz/friendly-snippets',
      'onsails/lspkind.nvim',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'
      require('luasnip.loaders.from_vscode').lazy_load()
      local compare = require 'cmp.config.compare'
      local WIDE_HEIGHT = 50

      local function setup_documentation_window()
        return {
          max_height = math.floor(WIDE_HEIGHT * (WIDE_HEIGHT / vim.o.lines)),
          max_width = math.floor(WIDE_HEIGHT * 2.5),
          border = 'rounded',
          col_offset = 5,
          side_padding = 2,
          winhighlight = 'Normal:Normal,FloatBorder:Normal,CursorLine:PmenuSel',
          zindex = 1001,
        }
      end

      -- Format the source and additional info based on language context
      local function format_completion_item(entry, item)
        local source_name = ({
          nvim_lsp = 'LSP',
          luasnip = 'Snippet',
          buffer = 'Buffer',
          path = 'Path',
        })[entry.source.name]

        local detail = entry.completion_item.detail
        -- local documentation = entry.completion_item.documentation
        -- local kind = entry.completion_item.kind

        -- Handle different completion items based on source and language
        if entry.source.name == 'nvim_lsp' then
          local bufnr = vim.api.nvim_get_current_buf()
          local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')

          if ft == 'rust' then
            -- Rust-specific formatting
            if detail then
              local crate = detail:match '%[(.+)%]$'
              if crate then
                item.menu = string.format('%s [ %s ] ', source_name, crate)
              end
            end
          elseif ft == 'python' then
            -- Python-specific formatting
            if detail then
              -- Extract function signature or type information
              local sig = detail:match '%(.*%)(.*)'
              if sig then
                item.menu = string.format('%s %s', source_name, sig)
              end
            end
          elseif ft == 'typescript' or ft == 'javascript' or ft == 'typescriptreact' or ft == 'javascriptreact' then
            -- TypeScript/JavaScript-specific formatting
            if detail then
              item.menu = string.format('%s %s', source_name, detail)
            end
          else
            -- Generic LSP formatting
            if detail then
              item.menu = string.format('%s %s', source_name, detail)
            else
              item.menu = source_name
            end
          end
        else
          item.menu = source_name
        end

        -- Add extra spacing after the kind symbol
        -- item.kind = string.format('%s ', item.kind)

        return item
      end

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = {
            border = 'rounded',
            winhighlight = 'Normal:Normal,FloatBorder:Normal,CursorLine:PmenuSel',
            scrollbar = true,
            col_offset = 0,
            side_padding = 1,
            scrolloff = 2,
            padding = { left = 1, right = 1 },
          },
          documentation = setup_documentation_window(),
        },
        completion = {
          completeopt = 'menu,menuone,noinsert', --,noselect',
          keyword_length = 1,
        },
        formatting = {
          expandable_indicator = true,
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            return lspkind.cmp_format {
              mode = 'symbol_text',
              maxwidth = 60,
              ellipsis_char = '...',
              before = function(entry, item)
                return format_completion_item(entry, item)
              end,
            }(entry, vim_item)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping {
            i = function(fallback)
              if cmp.visible() then
                cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
              else
                fallback()
              end
            end,
          },
          ['<C-p>'] = cmp.mapping {
            i = function(fallback)
              if cmp.visible() then
                cmp.select_prev_item { behavior = cmp.SelectBehavior.Select }
              else
                fallback()
              end
            end,
          },
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            -- Deprioritize snippets slightly
            function(entry1, entry2)
              local kind1 = entry1:get_kind()
              local kind2 = entry2:get_kind()
              if kind1 ~= kind2 then
                if kind1 == require('cmp.types').lsp.CompletionItemKind.Snippet then
                  return false
                end
                if kind2 == require('cmp.types').lsp.CompletionItemKind.Snippet then
                  return true
                end
              end
              return nil
            end,
            compare.offset,
            compare.exact,
            compare.score,
            compare.recently_used,
            compare.locality,
            compare.kind,
            compare.sort_text,
            compare.length,
            compare.order,
          },
        },
        sources = cmp.config.sources {
          {
            name = 'nvim_lsp',
            priority = 1000,
            entry_filter = function(entry, ctx)
              return require('cmp.types').lsp.CompletionItemKind[entry:get_kind()] ~= 'Text'
            end,
          },
          { name = 'luasnip', priority = 750 },
          { name = 'buffer', priority = 500 },
          { name = 'path', priority = 250 },
        },
        experimental = {
          ghost_text = false,
        },
      }

      -- Enhance documentation display for all files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { '*' },
        callback = function()
          local group = vim.api.nvim_create_augroup('CmpDocumentation', { clear = true })
          vim.api.nvim_create_autocmd('CompleteChanged', {
            group = group,
            buffer = 0,
            callback = function()
              if cmp.visible() then
                if not cmp.visible_docs() then
                  cmp.show_docs()
                end
              end
            end,
          })
        end,
      })
    end,
  },
}
