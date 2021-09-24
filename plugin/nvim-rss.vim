"
" DEVLOPMENT CODE START
"
fun! ReloadPlugin()
  lua package.loaded["nvim-rss"] = nil
  lua require("nvim-rss").print_debug("This works")
endfun
"
" DEVLOPMENT CODE END
"
