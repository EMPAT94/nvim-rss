"""""" DEVLOPMENT CODE START """"""

" Assuming vim started in nvim-rss directory
set rtp+=.

fun! ReloadPlugin()
  messages clear

  " lua package.loaded["nvim-rss"] = nil
  " lua require("nvim-rss").setup { feeds_file = "~/nvim.rss" }

  lua package.loaded["nvim-rss.modules.db"] = nil
  lua require("nvim-rss.modules.db")._verify_feed_list_exists()
endfun

nnoremap <C-e> :call ReloadPlugin()<CR>

echo "Ready to play!"

""""""" DEVLOPMENT CODE END """"""
