"""""" DEVLOPMENT CODE START """"""

" Assuming vim started in nvim-rss directory
set rtp+=.

fun! ReloadPlugin()
  messages clear
  lua package.loaded["nvim-rss"] = nil
  lua package.loaded["nvim-rss.modules.db"] = nil
endfun

nnoremap <C-e> :call ReloadPlugin()<CR>

command! FetchFeed lua require("nvim-rss").fetch_feed()
command! OpenRssView lua require("nvim-rss").open_feeds_tab()

echo "Ready to play!"

""""""" DEVLOPMENT CODE END """"""
