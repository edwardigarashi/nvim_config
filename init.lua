-- init.lua

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.g.python3_host_prog = "/opt/homebrew/bin/python3"

vim.cmd([[packadd packer.nvim]])

require("packer").startup(function(use)
  use "wbthomason/packer.nvim"

  -- Core
  use "neovim/nvim-lspconfig"
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"

  -- Rust
  use "mrcjkb/rustaceanvim"

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    run = ':TSUpdate',
  }
  -- Completion
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-nvim-lua"
  use "hrsh7th/cmp-nvim-lsp-signature-help"
  use "hrsh7th/cmp-vsnip"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/vim-vsnip"
  use "hrsh7th/cmp-calc"

  -- Telescope
  use {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    requires = { { "nvim-lua/plenary.nvim" } },
  }

  -- Markdown preview
  use {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
  }

  -- File tree
  use "nvim-tree/nvim-tree.lua"

  -- AI
  use {
    "olimorris/codecompanion.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  }

  -- Folding
  use {
    "kevinhwang91/nvim-ufo",
    requires = "kevinhwang91/promise-async",
  }

  -- Optional debugger
  -- Comment this out if you do not need it right now
  -- use "puremourning/vimspector"
end)

-- Mason
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("mason-lspconfig").setup()

-- Diagnostics signs
local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = "",
  })
end

sign({ name = "DiagnosticSignError", text = "⛔" })
sign({ name = "DiagnosticSignWarn",  text = "⚠️" })
sign({ name = "DiagnosticSignHint",  text = "❔" })
sign({ name = "DiagnosticSignInfo",  text = "ℹ️" })

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  update_in_insert = true,
  underline = true,
  severity_sort = false,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})

-- Format command
vim.api.nvim_create_user_command("Format", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client.server_capabilities.documentFormattingProvider then
      vim.lsp.buf.format({ async = true })
      return
    end
  end
  print("No LSP server attached that supports formatting")
end, { desc = "Format current buffer using LSP" })

-- LSP capabilities for cmp
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Neovim 0.11+ LSP style
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.enable("lua_ls")

-- rustaceanvim
-- Do not also manually set up rust_analyzer through lspconfig.
vim.g.rustaceanvim = {
  server = {
    capabilities = capabilities,
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "K", function()
        vim.lsp.buf.hover()
      end, { buffer = bufnr, silent = true })

      vim.keymap.set("n", "<Leader>a", function()
        vim.lsp.buf.code_action()
      end, { buffer = bufnr, silent = true })
    end,
    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
        },
      },
    },
  },
}

-- Completion
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<C-S-f>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }),
  }),
  sources = {
    { name = "path" },
    { name = "nvim_lsp", keyword_length = 2 },
    { name = "nvim_lsp_signature_help" },
    { name = "nvim_lua", keyword_length = 2 },
    { name = "buffer", keyword_length = 2 },
    { name = "vsnip", keyword_length = 2 },
    { name = "calc" },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    fields = { "menu", "abbr", "kind" },
    format = function(entry, item)
      local menu_icon = {
        nvim_lsp = "λ",
        vsnip = "⋗",
        buffer = "Ω",
        path = "🖫",
        calc = "∑",
      }
      item.menu = menu_icon[entry.source.name]
      return item
    end,
  },
})

-- Treesitter
local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
if ok then
  ts_configs.setup({
    ensure_installed = { "lua", "rust", "toml" },
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = nil,
    },
  })
end

-- Telescope
require("telescope").setup({})
vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, {})
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, {})
vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, {})
vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, {})

-- Nvim Tree
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
    icons = {
      webdev_colors = false,
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
      glyphs = {
        default = "📄",
        symlink = "🔗",
        folder = {
          arrow_closed = "▶",
          arrow_open = "▼",
          default = "📁",
          open = "📂",
          empty = "🗋",
          empty_open = "🗁",
        },
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "═",
          renamed = "➜",
          untracked = "★",
          deleted = "🗑️",
          ignored = "◌",
        },
      },
    },
  },
  filters = {
    dotfiles = false,
  },
})

-- CodeCompanion
require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "openai",
    },
    inline = {
      adapter = "openai",
    },
    cmd = {
      adapter = "gemma3",
    },
  },
  adapters = {
    openai = function()
      return require("codecompanion.adapters").extend("openai", {
        schema = {
          model = {
            default = "gpt-4o",
            choices = {
              "gpt-4o",
              "o1-mini",
            },
          },
        },
      })
    end,
    gemma3 = function()
      return require("codecompanion.adapters").extend("ollama", {
        name = "gemma3",
        schema = {
          model = {
            default = "gemma3:latest",
            choices = {
              "gemma3:latest",
            },
          },
        },
      })
    end,
  },
  opts = {
    log_level = "DEBUG",
  },
  display = {
    chat = {
      window = {
        position = "right",
      },
    },
  },
})

-- UFO
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

require("ufo").setup({
  provider_selector = function(_, _, _)
    return { "treesitter", "indent" }
  end,
})
