-- TODO Split code into proper functions and modules
local M = {}

-- TODO Move to constants.lua maybe ?
local cmd = vim.cmd
local api = vim.api
local spawn = vim.loop.spawn
local new_pipe = vim.loop.new_pipe
local wrap = vim.schedule_wrap
local curl = "curl"

-- TODO rockspec ? Check how to install module as dependency
local feedparser = require("feedparser")

local db = require("nvim-rss.modules.db")

-- TODO Better default name and path
local options = {
  feeds_file = "~/nvim.rss",
  -- verbose = false,
}

-- Open rss view in new tab
function M.open_feeds_tab()
  cmd("tabnew " .. options.feeds_file)
end

-- Refresh content for feed under cursor
function M.fetch_feed()
  local xmlUrl = api.nvim_get_current_line()
  -- local xmlUrl = "https://www.priteshtupe.com/feed.xml"
  -- TODO Add filter for non-url lines

  print("Fetching feed " .. xmlUrl .. "... ")

  local raw_feed = ""
  local stdin = new_pipe(false)
  local stdout = new_pipe(false)
  local stderr = new_pipe(false)

  handle = spawn(curl, {
    args = { xmlUrl },
    stdio = { stdin, stdout, stderr },
  }, wrap(function(err, msg)
    parse_data(raw_feed, xmlUrl)

    stdin:shutdown()
    stdout:read_stop()
    stderr:read_stop()
    stdin:close()
    stdout:close()
    stderr:close()

    if (not handle:is_closing()) then handle:close() end
  end))

  stdout:read_start(wrap(function(err, chunk)
    if (err) then error(err) end
    if (chunk) then raw_feed = raw_feed .. chunk end
  end))

  stderr:read_start(wrap(function(err, msg)
    if (err) then error(err, msg) end
  end))
end

function parse_data(raw_feed, xmlUrl)
  local parsed_feed = feedparser.parse(raw_feed)
  if (not parsed_feed) then
    print("Feed could not be parsed")
    -- TODO advanced options
    error(raw_feed)
    return
  end
  raw_feed = ""
  parsed_feed.xmlUrl = xmlUrl
  db.update_feed(parsed_feed)
  open_entries_split(parsed_feed)
end

function open_entries_split(parsed_feed)
  local feed_info, entries = db.read_feed(parsed_feed.xmlUrl)

  cmd([[
    let win = bufwinnr("__FEED__")

    if win == -1
      vsplit __FEED__
      setlocal buftype=nofile
      setlocal nobackup noswapfile nowritebackup
      setlocal noautoindent nosmartindent
      setlocal ft=markdown
      setlocal conceallevel=2
    else
      exe win . "wincmd w"
      normal! ggdG
    endif
  ]])

  _insert_feed_info_into_buffer(feed_info)

  _insert_entries_into_buffer(entries)
end

function _insert_feed_info_into_buffer(feed_info)
  cmd("normal i ========================================")
  cmd("normal o")
  cmd("normal o __" .. feed_info.title .. "__")
  cmd("normal o")
  cmd("normal o _" .. feed_info.htmlUrl .. "_")
  cmd("normal o")
  cmd("normal o " .. feed_info.subtitle)
  cmd("normal o")

  -- TODO Enable advanced options for user
  if (false) then
    cmd("normal o VERSION : " .. feed_info.version)
    cmd("normal o FORMAT : " .. feed_info.format)
    cmd("normal o UPDATED : " .. feed_info.updated)
    cmd("normal o RIGHTS : " .. feed_info.rights)
    cmd("normal o GENERATOR : " .. feed_info.generator)
    cmd("normal o AUTHOR : " .. feed_info.author)
  end

  cmd("normal o ========================================")
end

function _insert_entries_into_buffer(entries)
  for i, entry in ipairs(entries) do
    cmd("normal o")
    cmd("normal o")
    cmd("normal o " .. entry.title .. "")
    cmd("normal o ----------------------------------------")
    cmd("normal o")
    cmd("normal o " .. entry.link)
    cmd("normal o")
    local sanitized = sanitize(entry.summary)
    cmd("normal o " .. sanitized)
  end
  cmd("0")
end

function sanitize(text)
  local str = tostring(text)
  local subed = str:gsub("<.->", "") -- Remove html markup
  return subed
end

function M.setup(user_options)
  for k, v in pairs(user_options) do options[k] = v end
end

-- TODO For dev, remove later
function _G.prints(...)
  local objects = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  print(table.concat(objects, "\n"))
end

return M
