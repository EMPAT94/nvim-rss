-- TODO Split code into proper functions and modules
local M = {}

local api = vim.api
local loop = vim.loop
local wrap = vim.schedule_wrap

-- TODO rockspec ? Check how to install module as dependency
local feedparser = require("feedparser")

-- TODO Better default name and path
local options = {
  feeds_file = "~/.feeds_file",
  -- verbose = false,
}

-- Open rss view in new tab
function M.open_feeds_tab()
  vim.cmd("tabnew " .. options.feeds_file)
end

-- Refresh content for feed under cursor
function M.fetch_feed()
  -- local url = api.nvim_get_current_line()
  print("Fetching data...")

  local raw_feed = ""
  local stdin = loop.new_pipe(false)
  local stdout = loop.new_pipe(false)
  local stderr = loop.new_pipe(false)

  handle = loop.spawn("curl", {
    args = { "https://www.priteshtupe.com/feed.xml" },
    stdio = { stdin, stdout, stderr },
  }, wrap(function(err, msg)
    parse_data(raw_feed)

    stdin:shutdown()
    stdout:read_stop()
    stderr:read_stop()
    stdin:close()
    stdout:close()
    stderr:close()
    handle:close()
  end))

  stdout:read_start(wrap(function(err, chunk)
    if (err) then error(err) end
    if (chunk) then raw_feed = raw_feed .. chunk end
    print (err, chunk)
  end))

  stderr:read_start(wrap(function(err, msg)
    if (err) then error(err, msg) end
  end))
end

function parse_data(raw_feed)
  local parsed = feedparser.parse(raw_feed)
  raw_feed = ""
  print("----------- FEED START ----------------")
  print("TITLE : ", parsed.feed.title)
  print("ENTRIES : ")
  for i, entry in ipairs(parsed.entries) do print(i .. " -> " .. entry.title) end
  print("----------- FEED END ----------------")
end

function M.setup(user_options)
  for k, v in pairs(user_options) do options[k] = v end
end

return M
