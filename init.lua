vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.statusline = "%<%f %h%m%r%=%-14.(%l:%c%) %p%%"

vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 99

-- vim.opt.syntax = "on"
vim.opt.mouse = "a" -- enable mouse
vim.opt.clipboard = "unnamedplus" -- copy yank to clipboard
vim.opt.cursorline = true -- highlight line with the cursor
vim.opt.scrolloff = 10 -- lines to keep above and below the cursor

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true -- show symbols for tabs and trailing spaces
vim.opt.signcolumn = "yes"
vim.opt.breakindent = true

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- keymaps
vim.keymap.set("n", "<Esc>", vim.cmd.nohlsearch, { desc = "Hide search highlights" })
vim.keymap.set("n", "<leader>I", "<Cmd>e $MYVIMRC<Cr>", { desc = "Open init.lua" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move to the left split" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move to the right split" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to the bottom split" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to the top split" })
vim.keymap.set("n", "<leader>ef", vim.cmd.Ex, { desc = "Explore files" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- disable annoying keys
vim.keymap.set({ "n", "i", "v" }, "<Up>", "")
vim.keymap.set({ "n", "i", "v" }, "<Down>", "")
vim.keymap.set({ "n", "i", "v" }, "<Left>", "")
vim.keymap.set({ "n", "i", "v" }, "<Right>", "")
vim.keymap.set({ "n", "i", "v" }, "<S-Up>", "")
vim.keymap.set({ "n", "i", "v" }, "<S-Down>", "")
vim.keymap.set({ "n", "i", "v" }, "<S-Left>", "")
vim.keymap.set({ "n", "i", "v" }, "<S-Right>", "")

-- autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Bootstrap lazy.nvim
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

-- Setup lazy.nvim
require("lazy").setup({
	{
		"https://github.com/folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},

		init = function()
			vim.cmd("colorscheme tokyonight-night")
			local colors = require("tokyonight.colors").setup()

			vim.api.nvim_set_hl(0, "LineNrAbove", { fg = colors.blue })
			vim.api.nvim_set_hl(0, "LineNrBelow", { fg = colors.blue })
			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		end,
	},
	{
		"https://github.com/lewis6991/gitsigns.nvim",
		opts = {
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end, { desc = "Next git hunk" })

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end, { desc = "Prev git hunk" })

				-- Actions
				map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Gitsigns Stage hunk" })
				map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Gitsigns Reset hunk" })
				map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Gitsigns Undo stage hunk" })
				map("v", "<leader>hs", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end)
				map("v", "<leader>hr", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end)
				map("v", "<leader>hu", function()
					gitsigns.undo_stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end)

				map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Gitsigns Stage buffer" })
				map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Gitsigns Reset buffer" })
				map("n", "<leader>hU", gitsigns.reset_buffer_index, { desc = "Gitsigns Undo stage buffer" })

				map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Gitsigns Preview hunk" })
				map("n", "<leader>hb", function()
					gitsigns.blame_line({ full = true })
				end, { desc = "Gitsigns Blame line" })
				map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Gitsigns Toggle like blame" })
				map("n", "<leader>hd", gitsigns.diffthis, { desc = "Gitsigns Diff against index" })
				map("n", "<leader>hD", function()
					gitsigns.diffthis("@")
				end, { desc = "Gitsigns Diff against last commit" })
				map("n", "<leader>td", gitsigns.toggle_deleted, { desc = "Gitsigns Toggle deleted" })

				-- Text object
				-- map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
			end,
		},
	},
	{
		"https://github.com/nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>sF", function()
				builtin.find_files({ no_ignore = true, hidden = true })
			end, { desc = "[S]earch All [F]iles" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]earch [B]uffers" })
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp tags" })

			--git keypaps
			vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Find Git Files" })
			vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Show [G]it [S]tatus" })
		end,
	},
	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			-- Define your formatters
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettierd" },
				typescript = { "prettierd" },
			},
			-- Set default options
			default_format_opts = {
				lsp_format = "fallback",
			},
			-- Set up format-on-save
			format_on_save = { timeout_ms = 1000 },
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			---@diagnostic disable-next-line: missing-fields
			configs.setup({
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"vimdoc",
					"javascript",
					"typescript",
					"tsx",
					"astro",
					"html",
					"css",
				},
				sync_install = false,
				auto_install = true,
				highlight = { enable = true },
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
	},
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v4.x",
		lazy = true,
		config = false,
	},
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = true,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{ "L3MON4D3/LuaSnip" },
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				sources = {
					{ name = "nvim_lsp" },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<Tab>"] = cmp.mapping.confirm({ select = true }),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
				}),
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
			})
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		cmd = { "LspInfo", "LspInstall", "LspStart" },
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
		},
		config = function()
			local lsp_zero = require("lsp-zero")

			-- lsp_attach is where you enable features that only work
			-- if there is a language server active in the file
			local lsp_attach = function(client, bufnr)
				local opts = { buffer = bufnr }

				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
				vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
				vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
				vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
				vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
				vim.keymap.set("n", "<leader>gr", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
				vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
				vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
			end

			lsp_zero.extend_lspconfig({
				sign_text = true,
				lsp_attach = lsp_attach,
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "tsserver", "astro", "eslint", "tailwindcss" },
				handlers = {
					-- this first function is the "default handler"
					-- it applies to every language server without a "custom handler"
					function(server_name)
						require("lspconfig")[server_name].setup({})
					end,
				},
			})
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
})
