local M = {}

local sanitize = require("nvim-rss.modules.utils").sanitize

function M.insert_entries(entries)
  local append = vim.fn.append
  local line = vim.fn.line

  for i, entry in ipairs(entries) do
    append(line("$"), "")
    append(line("$"), "")
    append(line("$"), entry.title)
    append(line("$"), "------------------------")
    append(line("$"), entry.link)
    append(line("$"), "")
    if (entry.summary) then
      append(line("$"), sanitize(entry.summary))
    end
  end

  vim.cmd("0")
end

function M.update_feed_line(xmlUrl, latest, total)
  vim.cmd([[ let win = bufwinnr("nvim.rss")]])
  vim.cmd("/" .. xmlUrl:gsub("/", "\\/"))
  vim.cmd("nohlsearch")
  vim.cmd("normal 0I ")
  vim.cmd("normal 0dth")
  vim.cmd("normal I[" .. latest .. "/" .. total .. "] ")
end

function M.insert_feed_info(feed_info)
  vim.cmd("normal o " .. feed_info.title)
  vim.cmd("center")
  vim.cmd("normal o")
  if feed_info.htmlUrl then
    vim.cmd("normal o " .. feed_info.htmlUrl)
    vim.cmd("center")
  end
  vim.cmd("normal o")
  if (feed_info.subtitle) then
    vim.cmd("normal o " .. feed_info.subtitle)
    vim.cmd("center")
  end
  vim.cmd("normal o")

  --[[ if (options.verbose) then
    vim.cmd("normal o VERSION : " .. feed_info.version)
    vim.cmd("normal o FORMAT : " .. feed_info.format)
    vim.cmd("normal o UPDATED : " .. feed_info.updated)
    vim.cmd("normal o RIGHTS : " .. feed_info.rights)
    vim.cmd("normal o GENERATOR : " .. feed_info.generator)
    vim.cmd("normal o AUTHOR : " .. feed_info.author)
  end ]]

  vim.cmd("normal o ========================================")
  vim.cmd("center")
end

function M.create_feed_buffer()
  vim.cmd([[

    let win = bufwinnr("__FEED__")

    if win == -1
      vsplit __FEED__
      setlocal buftype=nofile
      setlocal nobackup noswapfile nowritebackup
      setlocal noautoindent nosmartindent
      setlocal nonumber norelativenumber
      setlocal filetype=markdown
    else
      exe win . "winvim.cmd w"
      normal! ggdG
    endif

  ]])
end

return M
