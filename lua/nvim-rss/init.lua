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
  -- local  xmlUrl = api.nvim_get_current_line()
  local xmlUrl = "https://www.priteshtupe.com/feed.xml"
  print("Fetching data...")

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
  raw_feed = ""
  parsed_feed.xmlUrl = xmlUrl
  db.update_feed(parsed_feed)
end

function M.setup(user_options)
  for k, v in pairs(user_options) do options[k] = v end
end

return M
