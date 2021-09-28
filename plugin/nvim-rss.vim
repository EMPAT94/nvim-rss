"""""" DEVLOPMENT CODE START """"""

" Assuming vim started in nvim-rss directory
set rtp+=.

fun! ReloadPlugin()
  messages clear

  lua package.loaded["nvim-rss"] = nil
  lua package.loaded["nvim-rss.modules.db"] = nil

  lua require("nvim-rss").fetch_feed()
endfun

nnoremap <C-e> :call ReloadPlugin()<CR>

echo "Ready to play!"

""""""" DEVLOPMENT CODE END """"""
