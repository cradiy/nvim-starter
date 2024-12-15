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
