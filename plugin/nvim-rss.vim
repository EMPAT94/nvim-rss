
"""""" DEVLOPMENT CODE START """"""

" Assuming vim started in nvim-rss directory
set rtp+=.

fun! ReloadPlugin()
  messages clear
  lua package.loaded["nvim-rss"] = nil
  lua require("nvim-rss").setup({ feeds_dir = "/home/pritesh/.config/nvim" })
endfun

nnoremap <C-e> :call ReloadPlugin()<CR>

command! FetchFeed lua require("nvim-rss").fetch_feed()
command! ViewFeed lua require("nvim-rss").view_feed()
command! FetchAllFeeds lua require("nvim-rss").fetch_all_feeds()
command! OpenRssView lua require("nvim-rss").open_feeds_tab()
" Must use full path
command! -nargs=1 ImportOpml lua require("nvim-rss").import_opml(<args>)

echo "Ready to play!"

""""""" DEVLOPMENT CODE END """"""
