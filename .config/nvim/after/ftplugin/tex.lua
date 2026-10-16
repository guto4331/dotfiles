vim.opt_local.spell = true
vim.opt_local.spelllang = { "en_us", "cjk" }
vim.b.undo_ftplugin = (vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | ") or "") .. "setlocal spell< spelllang<"
