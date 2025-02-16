return {
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      { 'folke/neodev.nvim', opts = {} },
      -- {'teal-language/toml.lua', config = true}
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('gy', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local function get_project_rustanalyzer_settings()
        local handle = io.open(vim.fn.resolve(vim.fn.getcwd() .. '/./rust-analyzer.json'))
        if not handle then
          return {}
        end
        local out = handle:read '*a'
        handle:close()
        local config = vim.json.decode(out)
        if type(config) == 'table' then
          return config
        end
        return {}
      end
      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pylsp = {
        --   settings = {
        --     pylsp = {
        --       plugins = {
        --         -- Disable linting/formatting in pylsp since we use ruff
        --         flake8 = { enabled = false },
        --         pycodestyle = { enabled = false },
        --         mccabe = { enabled = false },
        --         pyflakes = { enabled = false },
        --         autopep8 = { enabled = false },
        --         yapf = { enabled = false },
        --         mypy = {
        --           enabled = true,
        --           live_mode = true,
        --           dmypy = true,
        --           strict = false,
        --         },
        --         -- Keep completion and navigation features
        --         jedi_completion = { enabled = true },
        --         jedi_definition = { enabled = true },
        --         jedi_references = { enabled = true },
        --         jedi_symbols = { enabled = true },
        --         rope_completion = { enabled = true },
        --       },
        --     },
        --   },
        -- },
        --
        pyright = {
          capabilities = (function()
            local caps = vim.lsp.protocol.make_client_capabilities()
            caps.textDocument.publishDiagnostics.tagSupport.valueSet = { 2 }
            return caps
          end)(),
          settings = {
            python = {
              analysis = {
                useLibraryCodeForTypes = true,
                diagnosticSeverityOverrides = {
                  reportUnusedVariable = false, -- or anything
                },
                typeCheckingMode = 'basic',
              },
            },
          },
        },
        -- mypy for type checking
        mypy = {
          settings = {
            mypy = {
              -- Enable incremental mode for better performance
              dmypy = true,
              -- Adjust severity levels if needed
              severity = {
                error = 'error',
                note = 'information',
              },
              -- mypy configuration
              config = {
                disallow_untyped_defs = true,
                check_untyped_defs = true,
                disallow_any_generics = false,
                disallow_incomplete_defs = false,
              },
            },
          },
        },

        -- ruff for linting and formatting
        ruff = {
          init_options = {
            settings = {
              format = { enabled = true },
              lint = { enabled = true },
              -- Disable features handled by other LSPs
              hover = { enabled = false },
              completion = { enabled = false },
            },
          },
          on_attach = function(client)
            client.server_capabilities.hoverProvider = false
            client.server_capabilities.completionProvider = false
            client.server_capabilities.signatureHelpProvider = false
          end,
        },
        -- pylsp = {
        --   settings = {
        --     pylsp = {
        --       plugins = {
        --         flake8 = {
        --           enabled = false,
        --         },
        --         mypy = {
        --           enabled = true,
        --         },
        --         pycodestyle = {
        --           enabled = false,
        --         },
        --         autopep8 = { enabled = false },
        --         mccabe = { enabled = false },
        --         pylint = { enabled = false },
        --         pyflakes = {
        --           enabled = false,
        --         },
        --       },
        --     },
        --   },
        -- },
        -- ruff = {
        --   -- trace = 'messages',
        --   -- init_options = {
        --   --   settings = {
        --   --     logLevel = 'debug',
        --   --   },
        --   -- },
        --   single_file_support = false,
        -- },
        clojure_lsp = {},
        -- pylsp = {
        --   settings = {
        --     pylsp = {
        --       plugins = {
        --         pylint = { enabled = false },
        --         pyflakes = { enabled = false },
        --         pycodestyle = { enabled = false },
        --         mccabe = { enabled = false },
        --       },
        --     },
        --   },
        -- },
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = vim.tbl_deep_extend(
              'force',
              {
                assist = {
                  importEnforceGranularity = true,
                  importPrefix = 'create',
                },
                cargo = {
                  allFeatures = true,
                  loadOutDirsFromCheck = true,
                  runBuildScripts = true,
                },
                checkOnSave = {
                  allFeatures = true,
                  command = 'clippy',
                  extraArgs = { '--no-deps' },
                },
                completion = {
                  autoimport = {
                    enable = true,
                  },
                  postfix = {
                    enable = true,
                  },
                  privateEditable = {
                    enable = true,
                  },
                  snippets = {
                    custom = true,
                  },
                  fullFunctionSignatures = {
                    enable = true,
                  },
                },
                diagnostics = {
                  enable = true,
                  experimental = {
                    enable = true,
                  },
                },
                hover = {
                  documentation = {
                    enable = true,
                    format = 'markdown',
                    maxLength = 9999,
                  },
                  actions = {
                    enable = true,
                    debug = true,
                    gotoTypeDef = true,
                    implementations = true,
                    references = true,
                  },
                },
                lens = {
                  enable = true,
                  debug = true,
                  implementations = true,
                  references = true,
                  methodReferences = true,
                },
              },
              get_project_rustanalyzer_settings(),
              {
                cargo = {
                  buildScripts = {
                    enable = true,
                    overrideCommand = nil,
                  },
                },
                procMacro = {
                  enable = true,
                  ignored = {},
                },
              }
            ),
          },
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            capabilities.textDocument.completion.completionItem.preselectSupport = false
            capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
            capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
            capabilities.textDocument.completion.completionItem.deprecatedSupport = true
            capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
            capabilities.textDocument.completion.completionItem.resolveSupport = {
              properties = {
                'documentation',
                'detail',
                'additionalTextEdits',
              },
            }
            return capabilities
          end)(),
        },
        buf_ls = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        eslint = {},
        cssls = {},
        -- css_variables = {},
        dockerls = {},
        jsonls = {},
        html = {},
        tsserver = {},
        ts_ls = {
          root_dir = function(fname)
            local has_deno_json = require('lspconfig').util.root_pattern('deno.json', 'deno.jsonc', 'deno.lock')(fname)
            local has_package_json = require('lspconfig').util.root_pattern 'package.json'(fname)
            -- Only return a root dir if we have a Deno config AND NO package.json
            -- Or if we have both but Deno config is closer to the file
            if has_package_json and not has_deno_json then
              print 'Has only package.json and no deno stuff!'
              return has_package_json
            end
            print 'Has detected deno stuff!'
            print('ts_ls package.json loc:', has_package_json)
            print('ts_ls deno loc:', has_deno_json)
            return nil
          end,
          single_file_support = false,
        },
        denols = {
          root_dir = function(fname)
            local has_deno_stuff = require('lspconfig').util.root_pattern('deno.json', 'deno.jsonc', 'deno.lock')(fname)
            print('denols deno loc:', has_deno_stuff)
            return has_deno_stuff
          end,
        },
        terraformls = {},
        tflint = {},
        yamlls = {
          -- on_attach = function(_, bufnr)
          --   print 'LSP attached'
          --   local yml = require 'yamlls'
          --   yml.setup {}
          --   -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
          -- end,
          settings = {
            yaml = {
              schemaStore = {
                url = '',
                enable = false,
              },
              schemas = require('schemastore').yaml.schemas(),
              customTags = {
                '!Base64 scalar',
                '!Cidr scalar',
                '!And sequence',
                '!Equals sequence',
                '!If sequence',
                '!Not sequence',
                '!Or sequence',
                '!Condition scalar',
                '!FindInMap sequence',
                '!GetAtt scalar',
                '!GetAtt sequence',
                '!GetAZs scalar',
                '!ImportValue scalar',
                '!Join sequence',
                '!Select sequence',
                '!Split sequence',
                '!Sub scalar',
                '!Transform mapping',
                '!Ref scalar',
              },
            },
          },
        },
        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()
      --   PATH = 'append',
      -- }

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys {}
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'html',
        'cssls',
        'eslint',
        'mypy',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            -- server_name = server_name == 'tsserver' and 'ts_ls' or server_name
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
