-- TODO For dev, remove later
function _G.prints(...)
  local objects = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    objects[#objects+1] = vim.inspect(v)
  end

  print(table.concat(objects, "\n"))
end

-- TODO rockspec ? Check how to install module as dependency
local feedparser = require("feedparser")

local db = require("nvim-rss.modules.db")
local utils = require("nvim-rss.modules.utils")
local buffer = require("nvim-rss.modules.buffer")

-- TODO Split code into proper functions and modules
-- TODO Move to constants.lua maybe ?
local cmd = vim.cmd
local api = vim.api
local spawn = vim.loop.spawn
local new_pipe = vim.loop.new_pipe
local wrap = vim.schedule_wrap
local curl = "curl"

local options = {}
local feeds_file
local feeds_db

function handle_error(err)
  db.close_if_open()
  error(err)
end

local function open_entries_split(parsed_feed)
  local feed_info, entries = db.read_feed(parsed_feed.xmlUrl)

  cmd([[
    let win = bufwinnr("__FEED__")

    if win == -1
      vsplit __FEED__
      setlocal buftype=nofile
      setlocal nobackup noswapfile nowritebackup
      setlocal noautoindent nosmartindent
      setlocal nonumber norelativenumber
      setlocal filetype=markdown
    else
      exe win . "wincmd w"
      normal! ggdG
    endif
  ]])

  buffer.insert_feed_info(feed_info)

  buffer.insert_entries(entries)
end

local function parse_data(raw_feed, xmlUrl)
  local parsed_feed = feedparser.parse(raw_feed)
  if (not parsed_feed) then handle_error(raw_feed) end
  raw_feed = ""
  parsed_feed.xmlUrl = xmlUrl
  db.update_feed(parsed_feed)
  open_entries_split(parsed_feed)
end

local M = {}

-- Open rss view in new tab
function M.open_feeds_tab()
  cmd("tabnew " .. feeds_file)
end

-- Refresh content for feed under cursor
function M.fetch_feed()
  local xmlUrl = api.nvim_get_current_line()

  if (not utils.is_url(xmlUrl)) then handle_error("Line under cursor not a valid url") end

  print("Fetching feed " .. xmlUrl .. "... ")

  local raw_feed = ""
  local stdin = new_pipe(false)
  local stdout = new_pipe(false)
  local stderr = new_pipe(false)

  handle = spawn(curl, {
    args = { "-L", "--user-agent", "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/90.0", xmlUrl },
    stdio = { stdin, stdout, stderr },
  }, wrap(function(err, msg)

    stdin:shutdown()
    stdout:read_stop()
    stderr:read_stop()

    stdin:close()
    stdout:close()
    stderr:close()

    if (not handle:is_closing()) then handle:close() end

    if (err ~= 0) then handle_error(err, msg) end

    parse_data(raw_feed, xmlUrl)
  end))

  stdout:read_start(wrap(function(err, chunk)
    if (err) then handle_error(err, chunk) end
    if (chunk) then raw_feed = raw_feed .. chunk end
  end))

  stderr:read_start(wrap(function(err, msg)
    if (err) then handle_error(err, msg) end
  end))
end

function M.import_opml(opml_file)
  print("Importing ", opml_file, "...")

  -- Read all feeds from file
  local feeds = {}
  for line in io.lines(opml_file) do
    local type = line:match("type=\"(.-)\"")
    local link = line:match("xmlUrl=\"(.-)\"")
    local title = line:match("title=\"(.-)\"")
    if not title then title = line:match("text=\"(.-)\"") end

    if type and title and link then
      feeds[#feeds + 1] = link
    end
  end

  -- Dump 'em into nvim.rss
  local nvim_rss, err = io.open(feeds_file, "a+")
  if err then handle_error(err) end
  nvim_rss:write("\n\nOPML IMPORT\n-----\n")
  nvim_rss:write(table.concat(feeds, "\n"))
  nvim_rss:flush()
  nvim_rss:close()

  -- Update db as well
end

function M.setup(user_options)
  -- setup options
  options.feeds_dir = user_options.feeds_dir or "~"
  options.verbose = user_options.verbose or false

  feeds_file = options.feeds_dir .. "/nvim.rss"
  feeds_db = options.feeds_dir .. "/nvim.rss.db"

  -- setup database
  db.create(feeds_db)
end

return M
