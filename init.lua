vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.syntax = "on"
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
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<Cr>", { desc = "Hide search highlights" })
vim.keymap.set("n", "<leader>I", "<Cmd>e $MYVIMRC<Cr>", { desc = "Open init.lua" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move to the left split" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move to the right split" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to the bottom split" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to the top split" })

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
				map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Gitsigns Stage buffer" })
				map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Gitsigns Reset buffer" })
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
				-- Visual modGitsigns e
				-- map('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
				-- map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)

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

			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find [F]iles" })

			--vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find [B]uffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find [H]elp tags" })

			--git keypaps
			vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Find [G]it [F]iles" })
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
})
