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

			local function select_latex_engine()
				local state = vim.b.vimtex
				if not state or not state.compiler then
					return
				end
				local luatex_classes = {
					ltjsarticle = true,
					ltjsreport = true,
					ltjsbook = true,
					ltjtarticle = true,
					ltjtreport = true,
					ltjtbook = true,
				}
				-- 同一秒内の保存ではVimTeXのpreamble cacheが更新されないため。
				vim.fn["vimtex#cache#clear"]("parser_preamble")
				local preamble = vim.fn["vimtex#parser#preamble"](state.tex, { root = state.root })
				for index, line in ipairs(preamble) do
					preamble[index] = vim.fn.substitute(line, [[\\\@<!%.*]], "", "")
				end
				local document_class =
					vim.fn.matchstr(table.concat(preamble, ""), [[\\documentclass[^{]*{\zs[^}]\+\ze}]])
				local rc_option = vim.fn["vimtex#compiler#latexmk#get_rc_opt"](state.root, "pdf_mode", 1, -1)
				local use_lualatex = luatex_classes[document_class]
					and vim.fn.eval("b:vimtex.get_tex_program()") == "_"
					and rc_option[2] == -1
				local previous_engine = vim.fn.eval("b:vimtex.compiler.get_engine()")
				vim.cmd([[
					if !has_key(b:vimtex.compiler, 'dotfiles_default_get_engine')
						let b:vimtex.compiler.dotfiles_default_get_engine = b:vimtex.compiler.get_engine
					endif
				]])
				if use_lualatex then
					vim.cmd([[let b:vimtex.compiler.get_engine = { -> '-lualatex' }]])
				else
					vim.cmd([[let b:vimtex.compiler.get_engine = b:vimtex.compiler.dotfiles_default_get_engine]])
				end
				if
					previous_engine ~= vim.fn.eval("b:vimtex.compiler.get_engine()")
					and vim.fn.eval("b:vimtex.compiler.is_running()") == 1
				then
					vim.cmd("VimtexStop")
				end
			end

			vim.api.nvim_create_autocmd("User", {
				group = vim.api.nvim_create_augroup("latex_select_engine", { clear = true }),
				pattern = "VimtexEventInitPost",
				callback = select_latex_engine,
			})

			vim.api.nvim_create_autocmd("BufWritePost", {
				group = vim.api.nvim_create_augroup("latex_compile_on_save", { clear = true }),
				pattern = "*.tex",
				callback = function()
					if vim.bo.filetype == "tex" and vim.fn.exists(":VimtexCompile") == 2 then
						select_latex_engine()
						vim.cmd("VimtexCompile!")
					end
				end,
			})
		end,
	},
}
