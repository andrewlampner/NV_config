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
vim.opt.tabstop = 4
vim.opt.softtabstop = 4 
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.keymap.set('i', '{<CR>', '{<CR>}<Esc>O', { noremap = true, silent = true })
vim.o.showmode = false
vim.o.updatetime = 250
vim.o.timeoutlen = 400
vim.o.scrolloff = 10
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.confirm = true


--This is the settings for the lualine status bar plugin.
local signs = { Error = "✘", Warn = "▲", Hint = "", Info = "ℹ" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

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
  -- Fuzzy Finder (Telescope)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({})
    end,
  },

-- LSP Support
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim' },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({ ensure_installed = { 'clangd' } })

      if vim.lsp.config then
        vim.lsp.config('clangd', {
          capabilities = vim.lsp.protocol.make_client_capabilities(),
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--header-insertion=never",
          },
        })
        vim.lsp.enable('clangd')
      else
        -- Fallback for older versions
        local lspconfig = require('lspconfig')
        lspconfig.clangd.setup({
          capabilities = vim.lsp.protocol.make_client_capabilities(),
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--header-insertion=never",
          },
        })
      end
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

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local ok, ts = pcall(require, 'nvim-treesitter.configs')
      if not ok then return end
      ts.setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc" },
        highlight = { enable = true },
      })
    end,
  },

  -- Catppuccin Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "mocha" })
      vim.cmd.colorscheme "catppuccin"
    end,
  },

  -- File Explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({ window = { width = 30 } })
    end,
  },

  -- Lualine
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'auto',
          icons_enabled = true,
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff'},
          lualine_c = {
            {
              'diagnostics',
              sources = { 'nvim_diagnostic' },
              sections = { 'error', 'warn', 'info', 'hint' },
              symbols = { error = '✘ ', warn = '▲ ', info = 'ℹ ', hint = ' ' },
            },
            'filename',
          },
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      })
    end,
  },

  -- Trouble.nvim
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
    },
  },

  -- Gitsigns
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- Which-key
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
      },
    },
  },
})

-- ========================================================================== --
-- 4. KEYMAPS
-- ========================================================================== --
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>t', ':belowright 15split | terminal<CR>i', { desc = 'Terminal' })
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal' })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to Definition' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })
vim.keymap.set('n', '<leader>ee', function() vim.diagnostic.setqflist() end, { desc = 'Problems' })
vim.keymap.set('n', '<leader>e', ':Neotree toggle left<CR>', { desc = 'Toggle Explorer' })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set('n', 'grr', builtin.lsp_references, { desc = '[G]oto [R]eferences' })
vim.keymap.set('n', 'gri', builtin.lsp_implementations, { desc = '[G]oto [I]mplementation' })
vim.keymap.set('n', 'grd', builtin.lsp_definitions, { desc = '[G]oto [D]efinition' })
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
