return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "<leader>e", "<Cmd>Neotree toggle<CR>", desc = "ファイルツリーを開閉" },
		},
		opts = {},
	},
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		cmd = "Telescope",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>ff", "<Cmd>Telescope find_files<CR>", desc = "ファイルを検索" },
			{ "<leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "全文を検索" },
			{ "<leader>fb", "<Cmd>Telescope buffers<CR>", desc = "バッファを検索" },
			{ "<leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "ヘルプを検索" },
		},
		opts = {},
	},
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = { "n", "v" },
				desc = "コードを整形",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				sh = { "shfmt" },
				bash = { "shfmt" },
			},
			format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
		},
	},
}
