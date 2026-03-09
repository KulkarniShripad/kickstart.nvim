local v = vim
v.g.mapleader = ' '
v.g.maplocalleader = ' '
v.g.have_nerd_font = false
v.o.number = true
v.o.relativenumber = true
v.o.mouse = 'a'
v.o.showmode = false
v.schedule(function() v.o.clipboard = 'unnamedplus' end)
v.o.breakindent = true
v.o.undofile = true
v.o.ignorecase = true
v.o.smartcase = true
v.o.signcolumn = 'yes'
v.o.updatetime = 250
v.o.timeoutlen = 300

v.opt.tabstop = 4        -- a tab visually equals 4 spaces
v.opt.shiftwidth = 4     -- indentation uses 4 spaces
v.opt.softtabstop = 4    -- pressing Tab inserts 4 spaces
v.opt.expandtab = true   -- convert tabs to spaces
v.opt.smartindent = true -- smart auto indentation

v.o.splitright = true
v.o.splitbelow = true

v.o.list = true
v.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

v.o.inccommand = 'split'

v.o.cursorline = true

v.o.scrolloff = 10

v.o.confirm = true

v.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

v.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = v.diagnostic.severity.WARN } },

    virtual_text = true,   -- Text shows up at the end of the line
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    jump = { float = true },
}

v.keymap.set('n', '<leader>q', v.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
v.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
v.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
v.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
v.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
v.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

v.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = v.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() v.hl.on_yank() end,
})

local lazypath = v.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (v.uv or v.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = v.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if v.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

local rtp = v.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        ---@module 'gitsigns'
        ---@type Gitsigns.Config
        ---@diagnostic disable-next-line: missing-fields
        opts = {
            signs = {
                -- add = { text = '+' }, ---@diagnostic disable-line: missing-fields
                change = { text = '~' }, ---@diagnostic disable-line: missing-fields
                -- delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
                -- topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
                -- changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
            },
        },
    },

    { -- File explorer
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        lazy = false,
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons',
            'MunifTanjim/nui.nvim',
        },
        config = function()
            require('neo-tree').setup({
                filesystem = {
                    follow_current_file = {
                        enabled = true,
                    },
                    hijack_netrw_behavior = "open_default",
                },
            })

            -- keymap to toggle explorer
            v.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = 'Toggle File Explorer' })
        end,
    },

    { -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        event = 'VimEnter',
        ---@module 'which-key'
        ---@type wk.Opts
        ---@diagnostic disable-next-line: missing-fields
        opts = {
            -- delay between pressing a key and opening which-key (milliseconds)
            delay = 0,
            icons = { mappings = v.g.have_nerd_font },

            -- Document existing key chains
            spec = {
                { '<leader>s', group = '[S]earch',    mode = { 'n', 'v' } },
                { '<leader>t', group = '[T]oggle' },
                { '<leader>h', group = 'Git [H]unk',  mode = { 'n', 'v' } },
                { 'gr',        group = 'LSP Actions', mode = { 'n' } },
            },
        },
    },

    { -- Fuzzy Finder (files, lsp, etc)
        'nvim-telescope/telescope.nvim',
        enabled = true,
        event = 'VimEnter',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { -- If encountering errors, see telescope-fzf-native README for installation instructions
                'nvim-telescope/telescope-fzf-native.nvim',

                -- `build` is used to run some command when the plugin is installed/updated.
                -- This is only run then, not every time Neovim starts up.
                build = 'make',

                -- `cond` is a condition used to determine whether this plugin should be
                -- installed and loaded.
                cond = function() return v.fn.executable 'make' == 1 end,
            },
            { 'nvim-telescope/telescope-ui-select.nvim' },

            -- Useful for getting pretty icons, but requires a Nerd Font.
            { 'nvim-tree/nvim-web-devicons',            enabled = v.g.have_nerd_font },
        },
        config = function()
            require('telescope').setup {
                -- You can put your default mappings / updates / etc. in here
                --  All the info you're looking for is in `:help telescope.setup()`
                --
                -- defaults = {
                --   mappings = {
                --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
                --   },
                -- },
                -- pickers = {}
                extensions = {
                    ['ui-select'] = { require('telescope.themes').get_dropdown() },
                },
            }

            -- Enable Telescope extensions if they are installed
            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')

            -- See `:help telescope.builtin`
            local builtin = require 'telescope.builtin'
            v.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
            v.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
            v.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
            v.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
            v.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string,
                { desc = '[S]earch current [W]ord' })
            v.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
            v.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
            v.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
            v.keymap.set('n', '<leader>s.', builtin.oldfiles,
                { desc = '[S]earch Recent Files ("." for repeat)' })
            v.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
            v.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

            v.api.nvim_create_autocmd('LspAttach', {
                group = v.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
                callback = function(event)
                    local buffer = event.buf

                    v.keymap.set('n', 'grr', builtin.lsp_references,
                        { buffer = buffer, desc = '[G]oto [R]eferences' })

                    v.keymap.set('n', 'gri', builtin.lsp_implementations,
                        { buffer = buffer, desc = '[G]oto [I]mplementation' })

                    v.keymap.set('n', 'grd', builtin.lsp_definitions,
                        { buffer = buffer, desc = '[G]oto [D]efinition' })

                    v.keymap.set('n', 'gO', builtin.lsp_document_symbols,
                        { buffer = buffer, desc = 'Open Document Symbols' })

                    v.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols,
                        { buffer = buffer, desc = 'Open Workspace Symbols' })

                    v.keymap.set('n', 'grt', builtin.lsp_type_definitions,
                        { buffer = buffer, desc = '[G]oto [T]ype Definition' })
                end,
            })

            v.keymap.set('n', '<leader>/', function()
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                })
            end, { desc = '[/] Fuzzily search in current buffer' })

            v.keymap.set(
                'n',
                '<leader>s/',
                function()
                    builtin.live_grep {
                        grep_open_files = true,
                        prompt_title = 'Live Grep in Open Files',
                    }
                end,
                { desc = '[S]earch [/] in Open Files' }
            )

            -- Shortcut for searching your Neovim configuration files
            v.keymap.set('n', '<leader>sn',
                function() builtin.find_files { cwd = v.fn.stdpath 'config' } end,
                { desc = '[S]earch [N]eovim files' })
        end,
    },

    -- LSP Plugins
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            {
                'mason-org/mason.nvim',
                ---@module 'mason.settings'
                ---@type MasonSettings
                ---@diagnostic disable-next-line: missing-fields
                opts = {},
            },
            'mason-org/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',

            { 'j-hui/fidget.nvim', opts = {} },

            'saghen/blink.cmp',
        },
        config = function()
            v.api.nvim_create_autocmd('LspAttach', {
                group = v.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or 'n'
                        v.keymap.set(mode, keys, func,
                            { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    map('grn', v.lsp.buf.rename, '[R]e[n]ame')

                    map('gra', v.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

                    map('grD', v.lsp.buf.declaration, '[G]oto [D]eclaration')

                    local client = v.lsp.get_client_by_id(event.data.client_id)
                    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
                        local highlight_augroup = v.api.nvim_create_augroup(
                            'kickstart-lsp-highlight', { clear = false })
                        v.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = v.lsp.buf.document_highlight,
                        })

                        v.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = v.lsp.buf.clear_references,
                        })

                        v.api.nvim_create_autocmd('LspDetach', {
                            group = v.api.nvim_create_augroup('kickstart-lsp-detach',
                                { clear = true }),
                            callback = function(event2)
                                v.lsp.buf.clear_references()
                                v.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    if client and client:supports_method('textDocument/inlayHint', event.buf) then
                        map('<leader>th',
                            function()
                                v.lsp.inlay_hint.enable(not v.lsp.inlay_hint
                                    .is_enabled { bufnr = event.buf })
                            end,
                            '[T]oggle Inlay [H]ints')
                    end
                end,
            })


            local ensure_installed = v.tbl_keys(servers or {})
            v.list_extend(ensure_installed, {
                -- You can add other tools here that you want Mason to install
            })

            require('mason-tool-installer').setup { ensure_installed = ensure_installed }
        end,
    },

    { -- Autoformat
        'stevearc/conform.nvim',
        event = { 'BufWritePre' },
        cmd = { 'ConformInfo' },
        keys = {
            {
                '<leader>f',
                function() require('conform').format { async = true, lsp_format = 'fallback' } end,
                mode = '',
                desc = '[F]ormat buffer',
            },
        },
        ---@module 'conform'
        ---@type conform.setupOpts
        opts = {
            notify_on_error = false,
            format_on_save = function(bufnr)
                local disable_filetypes = { c = true, cpp = true }
                if disable_filetypes[v.bo[bufnr].filetype] then
                    return nil
                else
                    return {
                        timeout_ms = 500,
                        lsp_format = 'fallback',
                    }
                end
            end,
            formatters_by_ft = {
                lua = { 'stylua' },
            },
        },
    },

    { -- Autocompletion
        'saghen/blink.cmp',
        event = 'VimEnter',
        version = '1.*',
        dependencies = {
            {
                'L3MON4D3/LuaSnip',
                version = '2.*',
                build = (function()
                    if v.fn.has 'win32' == 1 or v.fn.executable 'make' == 0 then return end
                    return 'make install_jsregexp'
                end)(),
                dependencies = {
                },
                opts = {},
            },
        },
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            keymap = {
                preset = 'default',
            },

            appearance = {
                nerd_font_variant = 'mono',
            },

            completion = {
                documentation = { auto_show = false, auto_show_delay_ms = 500 },
            },

            sources = {
                default = { 'lsp', 'path', 'snippets' },
            },

            snippets = { preset = 'luasnip' },

            fuzzy = { implementation = 'lua' },

            signature = { enabled = true },
        },
    },

    { -- Colorscheme
        'rose-pine/neovim',
        name = 'rose-pine',
        priority = 1000,
        config = function()
            require('rose-pine').setup({
                variant = "main", -- main | moon | dawn
                disable_background = true,
                disable_float_background = true,
            })

            v.cmd.colorscheme('rose-pine')

            -- ensure transparency
            local transparent_groups = {
                "Normal",
                "NormalNC",
                "EndOfBuffer",
                "SignColumn",
                "NormalFloat",
                "FloatBorder",
            }

            for _, group in ipairs(transparent_groups) do
                v.api.nvim_set_hl(0, group, { bg = "none" })
            end
        end,
    },

    { -- Statusline
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'rose-pine', -- matches your rose-pine colorscheme
                    icons_enabled = true,
                    component_separators = '|',
                    section_separators = '',
                },
            })
        end,
    },

    { -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        build = ':TSUpdate',
        branch = 'main',
        config = function()
            local parsers = { 'bash', 'c', 'diff', 'html', 'lua',
                'vim',
                'vimdoc' }
            require('nvim-treesitter').install(parsers)
            v.api.nvim_create_autocmd('FileType', {
                callback = function(args)
                    local buf, filetype = args.buf, args.match

                    local language = v.treesitter.language.get_lang(filetype)
                    if not language then return end

                    if not v.treesitter.language.add(language) then return end
                    v.treesitter.start(buf, language)

                    v.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },

}, { ---@diagnostic disable-line: missing-fields
    ui = {
        icons = v.g.have_nerd_font and {} or {
            cmd = '⌘',
            config = '🛠',
            event = '📅',
            ft = '📂',
            init = '⚙',
            keys = '🗝',
            plugin = '🔌',
            runtime = '💻',
            require = '🌙',
            source = '📄',
            start = '🚀',
            task = '📌',
            lazy = '💤 ',
        },
    },
})

local servers = {
    "clang-format",
    "lua_ls",
    "nil_ls",
    "ts_ls",
    "jdtls",
    "python-lsp-server",
}

for _, server in ipairs(servers) do
    v.lsp.config(server, {})
    v.lsp.enable(server)
end
