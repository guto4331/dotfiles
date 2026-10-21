return {
	{
		"lervag/vimtex",
		lazy = false,
		init = function()
			vim.g.tex_flavor = "latex"
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_compiler_latexmk_engines = {
				_ = "-pdf",
				pdflatex = "-pdf",
				lualatex = "-lualatex",
			}
			vim.g.vimtex_compiler_latexmk = { continuous = 1, callback = 1 }
			vim.g.vimtex_view_method = "general"
			vim.g.vimtex_view_automatic = 1

			vim.api.nvim_create_autocmd("BufWritePost", {
				group = vim.api.nvim_create_augroup("latex_compile_on_save", { clear = true }),
				pattern = "*.tex",
				callback = function()
					if vim.bo.filetype == "tex" and vim.fn.exists(":VimtexCompile") == 2 then
						vim.cmd("VimtexCompile!")
					end
				end,
			})
		end,
	},
}
