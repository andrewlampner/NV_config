-- ========================================================================== --
-- 1. SETTINGS & UI
-- ========================================================================== --
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.mouse = 'a'
vim.opt.undofile = true
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.tabstop = 4      -- Visual width of a tab
vim.opt.softtabstop = 4  -- Number of spaces a tab counts for while editing
vim.opt.shiftwidth = 4   -- Size of an indent
vim.opt.expandtab = true -- Turn tabs into spaces
vim.keymap.set('i', '{<CR>', '{<CR>}<Esc>O', { noremap = true, silent = true })

-- ========================================================================== --
-- 2. LAZY.NVIM BOOTSTRAP
-- ========================================================================== --
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
-- 3. PLUGIN DEFINITIONS
-- ========================================================================== --
require('lazy').setup({
  -- LSP Support
  {
    'neovim/nvim-lspconfig',
    dependencies = { 
      'williamboman/mason.nvim', 
      'williamboman/mason-lspconfig.nvim' 
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({ ensure_installed = { 'clangd' } })
      
      vim.lsp.config('clangd', {
        cmd = { 
          "clangd", 
          "--background-index", 
          "--clang-tidy", 
          "--clang-tidy-checks=-*,cppcoreguidelines-*,modernize-*,performance-*,bugprone-*,readability-identifier-naming",
          "--completion-style=detailed",
          "--header-insertion=never",
        },
      })
      vim.lsp.enable('clangd')
    end,
  },


  -- Debugger (DAP)
  {
    'mfussenegger/nvim-dap',
    dependencies = { 'rcarriga/nvim-dap-ui', 'nvim-neotest/nvim-nio' },
    config = function()
      local ok_dap, dap = pcall(require, 'dap')
      local ok_ui, dapui = pcall(require, 'dapui')
      if ok_dap and ok_ui then
        dapui.setup()
      end
    end,
  },

  -- Treesitter (CRASH FIX)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      -- Use pcall (protected call) to prevent the "module not found" crash
      local ok, ts = pcall(require, 'nvim-treesitter.configs')
      if not ok then return end
      ts.setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc" },
        highlight = { enable = true },
      })
    end,
  },

-- Catppuccin Theme (Dark Mode)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- mocha is the darkest, macchiato is medium-dark
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },
})

-- ========================================================================== --
-- 4. KEYMAPS
-- ========================================================================== --
vim.keymap.set('n', '<leader>t', ':belowright 15split | terminal<CR>i', { desc = 'Terminal' })
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal' })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to Definition' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })
vim.keymap.set('n', '<leader>ee', function() vim.diagnostic.setqflist() end, { desc = 'Problems' })

-- ========================================================================== --
-- 5. DIAGNOSTICS & APPEARANCE (NEOVIM 0.11+ VERSION)
-- ========================================================================== --
vim.diagnostic.config({
  virtual_text = false, -- Keep inline errors OFF
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN]  = ' ',
      [vim.diagnostic.severity.HINT]  = ' ',
      [vim.diagnostic.severity.INFO]  = ' ',
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
