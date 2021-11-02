local BUFFER = {}

local sanitize = require("nvim-rss.modules.utils").sanitize

local cmd = vim.cmd

function BUFFER.insert_entries(entries)
  local a = vim.fn.append
  local l = vim.fn.line

  for i, entry in ipairs(entries) do
    a(l("$"), "")
    a(l("$"), "")
    a(l("$"), entry.title)
    a(l("$"), "------------------------")
    a(l("$"), entry.link)
    a(l("$"), "")
    if (entry.summary) then a(l("$"), sanitize(entry.summary)) end
  end

  cmd("0")
end

function BUFFER.insert_feed_info(feed_info)
  cmd("normal o " .. feed_info.title)
  cmd("center")
  cmd("normal o")
  if feed_info.htmlUrl then
    cmd("normal o " .. feed_info.htmlUrl)
    cmd("center")
  end
  cmd("normal o")
  if (feed_info.subtitle) then
    cmd("normal o " .. feed_info.subtitle)
    cmd("center")
  end
  cmd("normal o")

  --[[ if (options.verbose) then
    cmd("normal o VERSION : " .. feed_info.version)
    cmd("normal o FORMAT : " .. feed_info.format)
    cmd("normal o UPDATED : " .. feed_info.updated)
    cmd("normal o RIGHTS : " .. feed_info.rights)
    cmd("normal o GENERATOR : " .. feed_info.generator)
    cmd("normal o AUTHOR : " .. feed_info.author)
  end ]]

  cmd("normal o ========================================")
  cmd("center")
end

return BUFFER
