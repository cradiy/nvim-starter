local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
    {
      "echasnovski/mini.pairs",
      enabled = false,
    },
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          vtsls = {
            -- explicitly add default filetypes, so that we can extend
            -- them in related extras
            filetypes = {
              "javascript",
              "javascriptreact",
              "javascript.jsx",
              "typescript",
              "typescriptreact",
              "typescript.tsx",
            },
            settings = {
              complete_function_calls = true,
              vtsls = {
                enableMoveToFileCodeAction = true,
                autoUseWorkspaceTsdk = true,
                experimental = {
                  maxInlayHintLength = 30,
                  completion = {
                    enableServerSideFuzzyMatch = true,
                  },
                },
              },
              typescript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                  completeFunctionCalls = true,
                },
                inlayHints = {
                  enumMemberValues = { enabled = true },
                  functionLikeReturnTypes = { enabled = true },
                  parameterNames = { enabled = "literals" },
                  parameterTypes = { enabled = true },
                  propertyDeclarationTypes = { enabled = true },
                  variableTypes = { enabled = true },
                },
              },
            },
          },
        },
      },
    },
    {
      "folke/noice.nvim",
      opts = {
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        routes = {
          {
            filter = {
              any = {
                { find = "%d+l, %d+b" },
                { find = "; after #%d+" },
                { find = "; before #%d+" },
              },
            },
            view = "mini",
          },
          {
            filter = {
              event = "notify",
              any = {
                { find = ".*information.*" },
              },
            },
            opts = { skip = true },
          },
          {
            filter = {
              event = "notify",
              kind = "error",
              any = {

                { find = ".*-32603.*" },
                { find = ".*-32802.*" },
              },
            },
            opts = { skip = true },
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
        },
      },
    },
    {
      "ibhagwan/fzf-lua",
      opts = function(_, opts)
        local config = require("fzf-lua.config")
        local actions = require("fzf-lua.actions")

        -- Quickfix
        config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
        config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
        config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
        config.defaults.keymap.fzf["ctrl-x"] = "jump"
        config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
        config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
        config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
        config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

        -- Trouble
        if LazyVim.has("trouble.nvim") then
          config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
        end

        -- Toggle root dir / cwd
        config.defaults.actions.files["ctrl-r"] = function(_, ctx)
          local o = vim.deepcopy(ctx.__call_opts)
          o.root = o.root == false
          o.cwd = nil
          o.buf = ctx.__CTX.bufnr
          LazyVim.pick.open(ctx.__INFO.cmd, o)
        end
        config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]
        config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

        local img_previewer ---@type string[]?
        for _, v in ipairs({
          { cmd = "kitty ", args = { "+kitten", "icat" } },
          { cmd = "ueberzug", args = {} },
          { cmd = "chafa", args = { "{file}", "--format=symbols" } },
          { cmd = "viu", args = { "-b" } },
        }) do
          -- img_previewer = vim.list_extend({ v.cmd }, v.args)
          if vim.fn.executable(v.cmd) == 1 then
            img_previewer = vim.list_extend({ v.cmd }, v.args)
            break
          end
        end

        return {
          "default-title",
          fzf_colors = true,
          fzf_opts = {
            ["--no-scrollbar  --walker-skip='target,build,node_modules'"] = true,
          },
          defaults = {
            -- formatter = "path.filename_first",
            formatter = "path.dirname_first",
          },
          previewers = {
            builtin = {
              extensions = {
                ["png"] = img_previewer,
                ["jpg"] = img_previewer,
                ["jpeg"] = img_previewer,
                ["gif"] = img_previewer,
                ["webp"] = img_previewer,
              },
              ueberzug_scaler = "fit_contain",
            },
          },
          -- Custom LazyVim option to configure vim.ui.select
          ui_select = function(fzf_opts, items)
            return vim.tbl_deep_extend("force", fzf_opts, {
              prompt = " ",
              winopts = {
                title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
                title_pos = "center",
              },
            }, fzf_opts.kind == "codeaction" and {
              winopts = {
                layout = "vertical",
                -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
                height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
                width = 0.5,
                preview = not vim.tbl_isempty(LazyVim.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
                  layout = "vertical",
                  vertical = "down:15,border-top",
                  hidden = "hidden",
                } or {
                  layout = "vertical",
                  vertical = "down:15,border-top",
                },
              },
            } or {
              winopts = {
                width = 0.5,
                -- height is number of items, with a max of 80% screen height
                height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
              },
            })
          end,
          winopts = {
            width = 0.8,
            height = 0.8,
            row = 0.5,
            col = 0.5,
            preview = {
              scrollchars = { "┃", "" },
            },
          },
          files = {
            cwd_prompt = false,
            actions = {
              ["alt-i"] = { actions.toggle_ignore },
              ["alt-h"] = { actions.toggle_hidden },
            },
          },
          grep = {
            actions = {
              ["alt-i"] = { actions.toggle_ignore },
              ["alt-h"] = { actions.toggle_hidden },
            },
          },
          lsp = {
            symbols = {
              symbol_hl = function(s)
                return "TroubleIcon" .. s
              end,
              symbol_fmt = function(s)
                return s:lower() .. "\t"
              end,
              child_prefix = false,
            },
            code_actions = {
              previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
            },
          },
        }
      end,
    },
    {
      "saghen/blink.cmp",
      version = not vim.g.lazyvim_blink_main and "*",
      build = vim.g.lazyvim_blink_main and "cargo build --release",
      opts_extend = {
        "sources.completion.enabled_providers",
        "sources.compat",
        "sources.default",
      },
      dependencies = {
        "rafamadriz/friendly-snippets",
        -- add blink.compat to dependencies
        {
          "saghen/blink.compat",
          optional = true, -- make optional so it's only enabled if any extras need it
          opts = {},
          version = not vim.g.lazyvim_blink_main and "*",
        },
      },
      event = "InsertEnter",

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        snippets = {
          expand = function(snippet)
            return LazyVim.cmp.expand(snippet)
          end,
        },
        appearance = {
          -- sets the fallback highlight groups to nvim-cmp's highlight groups
          -- useful for when your theme doesn't support blink.cmp
          -- will be removed in a future release, assuming themes add support
          use_nvim_cmp_as_default = false,
          -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
          -- adjusts spacing to ensure icons are aligned
          nerd_font_variant = "mono",
        },
        completion = {
          accept = {
            -- experimental auto-brackets support
            auto_brackets = {
              enabled = false,
            },
          },
          menu = {
            draw = {
              treesitter = { "lsp" },
            },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
          },
          ghost_text = {
            -- enabled = vim.g.ai_cmp,
            enabled = false,
          },
          trigger = {
            show_on_insert_on_trigger_character = false,
            show_on_accept_on_trigger_character = false,
          },
          list = {
            selection = { preselect = false, auto_insert = false },
          },
        },

        -- experimental signature help support
        -- signature = { enabled = true },

        sources = {
          -- adding any nvim-cmp sources here will enable them
          -- with blink.compat
          compat = {},
          default = { "lsp", "path", "snippets", "buffer" },
          cmdline = {},
        },

        keymap = {
          preset = "enter",
          ["<C-y>"] = { "select_and_accept" },
          ["<C-j>"] = { "select_next" },
          ["<C-k>"] = { "select_prev" },
        },
      },
      ---@param opts blink.cmp.Config | { sources: { compat: string[] } }
      config = function(_, opts)
        -- setup compat sources
        local enabled = opts.sources.default
        for _, source in ipairs(opts.sources.compat or {}) do
          opts.sources.providers[source] = vim.tbl_deep_extend(
            "force",
            { name = source, module = "blink.compat.source" },
            opts.sources.providers[source] or {}
          )
          if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
            table.insert(enabled, source)
          end
        end

        -- add ai_accept to <Tab> key
        -- if not opts.keymap["<Tab>"] then
        --   if opts.keymap.preset == "super-tab" then -- super-tab
        --     opts.keymap["<Tab>"] = {
        --       require("blink.cmp.keymap.presets")["super-tab"]["<Tab>"][1],
        --       LazyVim.cmp.map({ "snippet_forward", "ai_accept" }),
        --       "fallback",
        --     }
        --   else -- other presets
        --     opts.keymap["<Tab>"] = {
        --       LazyVim.cmp.map({ "snippet_forward", "ai_accept" }),
        --       "fallback",
        --     }
        --   end
        -- end

        -- Unset custom prop to pass blink.cmp validation
        opts.sources.compat = nil

        -- check if we need to override symbol kinds
        for _, provider in pairs(opts.sources.providers or {}) do
          ---@cast provider blink.cmp.SourceProviderConfig|{kind?:string}
          if provider.kind then
            local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
            local kind_idx = #CompletionItemKind + 1

            CompletionItemKind[kind_idx] = provider.kind
            ---@diagnostic disable-next-line: no-unknown
            CompletionItemKind[provider.kind] = kind_idx

            ---@type fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
            local transform_items = provider.transform_items
            ---@param ctx blink.cmp.Context
            ---@param items blink.cmp.CompletionItem[]
            provider.transform_items = function(ctx, items)
              items = transform_items and transform_items(ctx, items) or items
              for _, item in ipairs(items) do
                item.kind = kind_idx or item.kind
              end
              return items
            end

            -- Unset custom prop to pass blink.cmp validation
            provider.kind = nil
          end
        end

        require("blink.cmp").setup(opts)
      end,
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      cmd = "Neotree",
      keys = {
        {
          "<leader>fe",
          function()
            require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
          end,
          desc = "Explorer NeoTree (Root Dir)",
        },
        {
          "<leader>fE",
          function()
            require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
          end,
          desc = "Explorer NeoTree (cwd)",
        },
        { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
        { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
        {
          "<leader>ge",
          function()
            require("neo-tree.command").execute({ source = "git_status", toggle = true })
          end,
          desc = "Git Explorer",
        },
        {
          "<leader>be",
          function()
            require("neo-tree.command").execute({ source = "buffers", toggle = true })
          end,
          desc = "Buffer Explorer",
        },
      },
      deactivate = function()
        vim.cmd([[Neotree close]])
      end,
      init = function()
        -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
        -- because `cwd` is not set up properly.
        vim.api.nvim_create_autocmd("BufEnter", {
          group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
          desc = "Start Neo-tree with directory",
          once = true,
          callback = function()
            if package.loaded["neo-tree"] then
              return
            else
              local stats = vim.uv.fs_stat(vim.fn.argv(0))
              if stats and stats.type == "directory" then
                require("neo-tree")
              end
            end
          end,
        })
      end,
      opts = {
        sources = { "filesystem", "buffers", "git_status" },
        open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
        filesystem = {
          bind_to_cwd = false,
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
        },
        window = {
          width = 30,
          mappings = {
            ["l"] = "open",
            ["h"] = "close_node",
            ["<space>"] = "none",
            ["Y"] = {
              function(state)
                local node = state.tree:get_node()
                local path = node:get_id()
                vim.fn.setreg("+", path, "c")
              end,
              desc = "Copy Path to Clipboard",
            },
            ["O"] = {
              function(state)
                require("lazy.util").open(state.tree:get_node().path, { system = true })
              end,
              desc = "Open with System Application",
            },
            ["P"] = { "toggle_preview", config = { use_float = false } },
          },
        },
        default_component_configs = {
          indent = {
            with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
          git_status = {
            symbols = {
              unstaged = "󰄱",
              staged = "󰱒",
            },
          },
        },
      },
      config = function(_, opts)
        local function on_move(data)
          Snacks.rename.on_rename_file(data.source, data.destination)
        end

        local events = require("neo-tree.events")
        opts.event_handlers = opts.event_handlers or {}
        vim.list_extend(opts.event_handlers, {
          { event = events.FILE_MOVED, handler = on_move },
          { event = events.FILE_RENAMED, handler = on_move },
        })
        require("neo-tree").setup(opts)
        vim.api.nvim_create_autocmd("TermClose", {
          pattern = "*lazygit",
          callback = function()
            if package.loaded["neo-tree.sources.git_status"] then
              require("neo-tree.sources.git_status").refresh()
            end
          end,
        })
      end,
    },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
