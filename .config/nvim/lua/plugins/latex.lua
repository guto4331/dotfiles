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

			vim.api.nvim_create_autocmd("User", {
				group = vim.api.nvim_create_augroup("latex_select_engine", { clear = true }),
				pattern = "VimtexEventInitPost",
				callback = function()
					local luatex_classes = {
						ltjsarticle = true,
						ltjsreport = true,
						ltjsbook = true,
						ltjtarticle = true,
						ltjtreport = true,
						ltjtbook = true,
					}
					local state = vim.b.vimtex
					if not state or not state.compiler or not luatex_classes[state.documentclass] then
						return
					end
					if vim.fn.eval("b:vimtex.get_tex_program()") ~= "_" then
						return
					end
					local rc_option = vim.fn["vimtex#compiler#latexmk#get_rc_opt"](state.root, "pdf_mode", 1, -1)
					if rc_option[2] ~= -1 then
						return
					end
					vim.cmd([[let b:vimtex.compiler.get_engine = { -> '-lualatex' }]])
				end,
			})

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
