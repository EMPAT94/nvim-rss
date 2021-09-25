" DEVLOPMENT CODE START
"
fun! ReloadPlugin()
  lua package.loaded["nvim-rss"] = nil
  lua require("nvim-rss").setup { feeds_file = "~/.feeds_file" }
endfun

nnoremap <C-e> :call ReloadPlugin()<CR>
nnoremap <C-]> :lua require("nvim-rss").open_feeds_tab()<CR>
nnoremap <C-\> :lua require("nvim-rss").fetch_feed()<CR>
"
" DEVLOPMENT CODE END


" TODO
" Change default name and path
" Make user editable
" lua require("nvim-rss").setup { feeds_file = "~/.feeds_file" }
