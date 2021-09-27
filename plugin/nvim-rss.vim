"""""" DEVLOPMENT CODE START """"""

" Assuming vim started in nvim-rss directory
set rtp+=.

fun! ReloadPlugin()
  lua package.loaded["nvim-rss"] = nil
  lua require("nvim-rss").setup { feeds_file = "~/.feeds_file" }
  messages clear
endfun

nnoremap <C-e> :call ReloadPlugin()<CR>
nnoremap <C-]> :lua require("nvim-rss").open_feeds_tab()<CR>
nnoremap <C-\> :lua require("nvim-rss").fetch_feed()<CR>

echo "Ready to play!"

""""""" DEVLOPMENT CODE END """"""
