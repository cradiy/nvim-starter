return {
  {
    "lewis6991/gitsigns.nvim",
  },
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   tag = "0.1.8",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   config = function()
  --     require("telescope").setup({
  --       defaults = {
  --         file_ignore_patterns = { "target", ".git", "node_modules", "build", "dist" },
  --       },
  --     })
  --   end,
  -- },
  { "akinsho/toggleterm.nvim", version = "*" },
  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     -- add any options here
  --   },
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "rcarriga/nvim-notify",
  --   },
  -- },
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      require("grug-far").setup({
        -- options, see Configuration section below
        -- there are no required options atm
        -- engine = 'ripgrep' is default, but 'astgrep' can be specified
      })
    end,
  },
  {
    "folke/edgy.nvim",
    ---@module 'edgy'
    ---@param opts Edgy.Config
    opts = function(_, opts)
      for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
        opts[pos] = opts[pos] or {}
        table.insert(opts[pos], {
          ft = "snacks_terminal",
          size = { height = 0.4 },
          title = "🦀 LazyTerm",
          filter = function(_buf, win)
            return vim.w[win].snacks_win
              and vim.w[win].snacks_win.position == pos
              and vim.w[win].snacks_win.relative == "editor"
              and not vim.w[win].trouble_preview
          end,
        })
      end
    end,
  },
  {
    "folke/snacks.nvim",
    config = function()
      require("snacks").setup({

        terminal = {
          bo = {
            filetype = "snacks_terminal",
          },
          wo = {},
          keys = {
            term_normal = {
              "<C-]>",
              function(self)
                vim.cmd("stopinsert")
              end,
              mode = "t",
              expr = true,
              desc = "Double escape to normal mode",
            },
          },
        },
      })
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        disable_filetype = { "TelescopePrompt", "vim" },
        fast_wrap = {
          chars = { "{", "[", "(", '"' },
          pattern = string.gsub([[ [%nvim-autopairs"%)%>%]%)%}%,] ]], "%s+", ""),
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "Search",
          highlight_grey = "Comment",
        },
      })
    end,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      file_types = { "markdown", "copilot-chat" },
    },
  },
  {
    "eero-lehtinen/oklch-color-picker.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- One handed keymap recommended, you will be using the mouse
      { "<leader>v", "<cmd>ColorPickOklch<cr>", desc = "Color pick under cursor" },
    },
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "cradiy/diffview.nvim",
    config = true,
  },
}
