-- init.lua

--------------------------------------------------
-- Core options
--------------------------------------------------
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.cursorline = true
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "

--------------------------------------------------
-- Bootstrap / load packer
--------------------------------------------------
vim.cmd([[packadd packer.nvim]])

require("packer").startup(function(use)
  use "wbthomason/packer.nvim"

  ------------------------------------------------
  -- LSP / tooling
  ------------------------------------------------
  use "neovim/nvim-lspconfig"
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"

  ------------------------------------------------
  -- Rust
  -- Pin for Neovim 0.11 compatibility
  ------------------------------------------------
  use {
    "mrcjkb/rustaceanvim",
    tag = "v8.0.5",
  }

  ------------------------------------------------
  -- Treesitter
  -- Use compatibility branch for Neovim 0.11
  ------------------------------------------------
  use {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    run = ":TSUpdate",
  }

  ------------------------------------------------
  -- Completion
  ------------------------------------------------
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-nvim-lua"
  use "hrsh7th/cmp-nvim-lsp-signature-help"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-buffer"
  use "L3MON4D3/LuaSnip"
  use "saadparwaiz1/cmp_luasnip"
  use "rafamadriz/friendly-snippets"
  use "windwp/nvim-autopairs"

  ------------------------------------------------
  -- Telescope
  ------------------------------------------------
  use {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    requires = {
      { "nvim-lua/plenary.nvim" },
    },
  }

  ------------------------------------------------
  -- Markdown preview
  ------------------------------------------------
  use {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
  }

  ------------------------------------------------
  -- File tree
  ------------------------------------------------
  use "nvim-tree/nvim-tree.lua"
  ------------------------------------------------
  -- AI
  ------------------------------------------------
  use {
    "olimorris/codecompanion.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  }

  ------------------------------------------------
  -- Folding
  -- Disabled for now while Treesitter mismatch is being avoided
  ------------------------------------------------
  -- use {
  --   "kevinhwang91/nvim-ufo",
  --   requires = "kevinhwang91/promise-async",
  -- }
end)

--------------------------------------------------
-- Mason
--------------------------------------------------
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "bashls",
    "jsonls",
    "yamlls",
    "html",
    "cssls",
    "pyright",
    "ts_ls",
  },
  automatic_installation = true,
})

--------------------------------------------------
-- Diagnostic signs
--------------------------------------------------
local function define_sign(name, text)
  vim.fn.sign_define(name, {
    texthl = name,
    text = text,
    numhl = "",
  })
end

define_sign("DiagnosticSignError", "⛔")
define_sign("DiagnosticSignWarn", "⚠")
define_sign("DiagnosticSignHint", "➤")
define_sign("DiagnosticSignInfo", "ℹ")

--------------------------------------------------
-- Diagnostics
--------------------------------------------------
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    source = "if_many",
    prefix = "●",
  },
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostics" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

--------------------------------------------------
-- Format command
--------------------------------------------------
vim.api.nvim_create_user_command("Format", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format current buffer using LSP" })

--------------------------------------------------
-- LSP capabilities
--------------------------------------------------
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()

--------------------------------------------------
-- Shared LSP attach behavior
--------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = bufnr, silent = true }

    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

--------------------------------------------------
-- Neovim 0.11+ LSP config
--------------------------------------------------
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
      completion = {
        callSnippet = "Replace",
      },
    },
  },
})
vim.lsp.enable("lua_ls")

vim.lsp.config("bashls", { capabilities = capabilities })
vim.lsp.enable("bashls")

vim.lsp.config("jsonls", { capabilities = capabilities })
vim.lsp.enable("jsonls")

vim.lsp.config("yamlls", { capabilities = capabilities })
vim.lsp.enable("yamlls")

vim.lsp.config("html", { capabilities = capabilities })
vim.lsp.enable("html")

vim.lsp.config("cssls", { capabilities = capabilities })
vim.lsp.enable("cssls")

vim.lsp.config("pyright", { capabilities = capabilities })
vim.lsp.enable("pyright")

vim.lsp.config("ts_ls", { capabilities = capabilities })
vim.lsp.enable("ts_ls")

--------------------------------------------------
-- rustaceanvim
--------------------------------------------------
vim.g.rustaceanvim = {
  server = {
    capabilities = capabilities,
    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
        },
        checkOnSave = true,
        procMacro = {
          enable = true,
        },
      },
    },
  },
}

--------------------------------------------------
-- Completion
--------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),

    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp", keyword_length = 1 },
    { name = "nvim_lsp_signature_help" },
    { name = "nvim_lua", keyword_length = 2 },
    { name = "luasnip" },
    { name = "path" },
  }, {
    { name = "buffer", keyword_length = 3 },
  }),

  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, item)
      local menu_icon = {
        nvim_lsp = "[LSP]",
        nvim_lua = "[Lua]",
        luasnip = "[Snip]",
        buffer = "[Buf]",
        path = "[Path]",
        nvim_lsp_signature_help = "[Sig]",
      }
      item.menu = menu_icon[entry.source.name] or ("[" .. entry.source.name .. "]")
      return item
    end,
  },
})

--------------------------------------------------
-- Autopairs
--------------------------------------------------
require("nvim-autopairs").setup({})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

--------------------------------------------------
-- Treesitter
--------------------------------------------------
local ok_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if ok_ts then
  ts_configs.setup({
    ensure_installed = {
      "bash",
      "c",
      "css",
      "dockerfile",
      "html",
      "javascript",
      "json",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "rust",
      "toml",
      "tsx",
      "typescript",
      "yaml",
      -- intentionally excluding "vim" and "vimdoc"
      -- because your current runtime/parser combo is throwing
      -- Invalid node type "substitute" for vim Treesitter queries
    },
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
      disable = { "vim", "vimdoc" },
    },
    indent = {
      enable = true,
      disable = { "vim", "vimdoc" },
    },
  })
end

--------------------------------------------------
-- Force classic syntax for Vimscript / vim help
--------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "vim", "help" },
  callback = function(args)
    pcall(vim.treesitter.stop, args.buf)
    vim.bo[args.buf].syntax = "vim"
  end,
})

--------------------------------------------------
-- Telescope
--------------------------------------------------
require("telescope").setup({})
local telescope_builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", telescope_builtin.help_tags, { desc = "Help tags" })

--------------------------------------------------
-- nvim-tree
--------------------------------------------------
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
      show = {
        file = false,
        folder = false,
        folder_arrow = false,
        git = false,
      },
    },
  },
  filters = {
    dotfiles = false,
  },
})

vim.keymap.set("n", "<leader>tt", "<cmd>NvimTreeToggle<CR>", {
  silent = true,
  desc = "Toggle tree",
})

--------------------------------------------------
-- CodeCompanion
--------------------------------------------------
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

--------------------------------------------------
-- Filetype specific settings
--------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
