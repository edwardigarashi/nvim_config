-- init.lua
vim.opt.tabstop = 4      -- Number of visual spaces per TAB
vim.opt.shiftwidth = 4   -- Number of spaces for each indentation level
vim.opt.expandtab = true -- Convert TAB to spaces
vim.cmd [[packadd packer.nvim]]
vim.opt.relativenumber = true
require('packer').startup(function(use)
  -- Packer manages itself
  use 'wbthomason/packer.nvim'
  -- Add your other plugins here, for example:
  use 'nvim-treesitter/nvim-treesitter'
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'    
  use 'williamboman/mason-lspconfig.nvim'	
  use 'simrat39/rust-tools.nvim'
  -- Completion framework:
  use 'hrsh7th/nvim-cmp' 

  -- LSP completion source:
  use 'hrsh7th/cmp-nvim-lsp'

  -- Useful completion sources:
  use 'hrsh7th/cmp-nvim-lua'
  use 'hrsh7th/cmp-nvim-lsp-signature-help'
  use 'hrsh7th/cmp-vsnip'                             
  use 'hrsh7th/cmp-path'                              
  use 'hrsh7th/cmp-buffer'                            
  use 'hrsh7th/vim-vsnip'
  use 'puremourning/vimspector'
  -- Telescope
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {'iamcco/markdown-preview.nvim', run = 'cd app && npm install'}
  use {
    'nvim-tree/nvim-tree.lua',
  }
  use {
   "olimorris/codecompanion.nvim",
   config = function()
     require("codecompanion").setup()
   end,
   requires = {
     "nvim-lua/plenary.nvim",
     "nvim-treesitter/nvim-treesitter",
   }
  }
   use {'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async'}
end)

-- Mason Setup
require("mason").setup({
    ui = {
        icons = {
        	package_installed = "✓",
      		package_pending = "➜",
      		package_uninstalled = "✗"
	},
    }
})
require("mason-lspconfig").setup()


-- Rust Analyzer Tool
--
local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})

-- Format Document LSP
vim.api.nvim_create_user_command("Format", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client.server_capabilities.documentFormattingProvider then
      vim.lsp.buf.format()
      return
    end
  end
  print("No LSP server attached that supports formatting")
end, { desc = "Format current buffer using LSP" })


-- LSP Diagnostics Options Setup 
local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = ''
  })
end

sign({name = 'DiagnosticSignError', text = '⛔'})
sign({name = 'DiagnosticSignWarn', text = '⚠️'})
sign({name = 'DiagnosticSignHint', text = '❔'})
sign({name = 'DiagnosticSignInfo', text = 'ℹ️'})

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = true,
    underline = true,
    severity_sort = false,
    float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})

vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])


-- Completion Plugin Setup
local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },
  -- Installed sources:
  sources = {
    { name = 'path' },                              -- file paths
    { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
    { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
    { name = 'buffer', keyword_length = 2 },        -- source current buffer
    { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip 
    { name = 'calc'},                               -- source for math calculation
  },
  window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
  },
  formatting = {
      fields = {'menu', 'abbr', 'kind'},
      format = function(entry, item)
          local menu_icon ={
              nvim_lsp = 'λ',
              vsnip = '⋗',
              buffer = 'Ω',
              path = '🖫',
          }
          item.menu = menu_icon[entry.source.name]
          return item
      end,
  },
})

-- Treesitter Plugin Setup
require('nvim-treesitter.configs').setup {
  ensure_installed = { "lua", "rust", "toml" },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting=false,
  },
  ident = { enable = true }, 
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  }
}

require('telescope').setup{}
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, {})
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, {})
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, {})
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, {})

-- NVIM Tree
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
      show = { file = true, folder = true, folder_arrow = true, git = true },
      glyphs = {
        default   = "📄",
        symlink   = "🔗",
        folder = {
          arrow_closed = "▶",
          arrow_open   = "▼",
          default       = "📁",
          open          = "📂",
          empty         = "🗋",
          empty_open    = "🗁",
        },
        git = {
          unstaged  = "✗",
          staged    = "✓",
          unmerged  = "═",
          renamed   = "➜",
          untracked = "★",
          deleted   = "🗑️",
          ignored   = "◌",
        },
      },
    },
  },
  filters = {
    dotfiles = true,
  },
})


-- Codecompanion
require("codecompanion").setup({
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    strategies = {
        -- Change the default chat adapter
        chat = {
            adapter = "openai",
        },
        inline = {
            adapter = "openai",
        },
        cmd = {
            adapter = "gemma3",
        }
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
                }
            },
            },
        })
        end,
        gemma3 = function()
            return require('codecompanion.adapters').extend('ollama', {
                name = 'gemma3',
                schema = {
                    model = {
                        default = 'gemma3:latest',
                        choices = {
                            'gemma3:latest',
                        }
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
    		    position = "right", -- "left" (default), "right", "top", or "bottom"
  		    },
	    },
    }
})

-- Nvim UFO
vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
require('ufo').setup({
    provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end
})
