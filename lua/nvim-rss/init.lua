local feedparser = require("feedparser")

local db = require("nvim-rss.modules.db")
local utils = require("nvim-rss.modules.utils")
local buffer = require("nvim-rss.modules.buffer")

local cmd = vim.cmd
local api = vim.api
local spawn = vim.loop.spawn
local new_pipe = vim.loop.new_pipe
local wrap = vim.schedule_wrap
local curl = "curl"

local options = {}
local feeds_file
local feeds_db

local function open_entries_split(parsed_feed)
  local feed_info, entries = db.read_feed(parsed_feed.xmlUrl)
  buffer.create_feed_buffer()
  buffer.insert_feed_info(feed_info)
  buffer.insert_entries(entries)
end

local function update_feed_line(parsed_feed)
  local latest, total = db.read_entry_stats(parsed_feed.xmlUrl)
  buffer.update_feed_line(parsed_feed.xmlUrl, latest, total)
end

local M = {}

-- Open rss view in new tab
function M.open_feeds_tab()
  cmd("tabnew " .. feeds_file)
end

local function web_request(url, callback)
  local raw_feed = ""
  local stdin = new_pipe(false)
  local stdout = new_pipe(false)
  local stderr = new_pipe(false)

  print("Fetching feed " .. url .. "... ")

  handle = spawn(curl, {
    args = { "-L", "--user-agent", "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/90.0", url },
    stdio = { stdin, stdout, stderr },
  }, wrap(function(err, msg)
    stdin:shutdown()
    stdout:read_stop()
    stderr:read_stop()

    stdin:close()
    stdout:close()
    stderr:close()

    if (not handle:is_closing()) then
      handle:close()
    end

    if (err ~= 0) then
      error("Web request error", err .. msg)
    end

    local parsed_feed = feedparser.parse(raw_feed)
    if (not parsed_feed) then
      error("Feed parsing error", raw_feed)
    end

    raw_feed = ""
    parsed_feed.xmlUrl = url
    db.update_feed(parsed_feed)

    callback(parsed_feed)
  end))

  stdout:read_start(wrap(function(err, chunk)
    if (err) then
      error(err, chunk)
    end
    if (chunk) then
      raw_feed = raw_feed .. chunk
    end
  end))

  stderr:read_start(wrap(function(err, chunk)
    if (err) then
      error(err, chunk)
    end
  end))
end

-- Refresh content for feed under cursor
function M.fetch_feed()
  local xmlUrl = utils.get_url(api.nvim_get_current_line())

  if (not xmlUrl) then
    error("Invalid url")
  end

  local function callback(parsed_feed)
    local latest, total = db.read_entry_stats(parsed_feed.xmlUrl)
    buffer.update_feed_line(parsed_feed.xmlUrl, latest, total)
    open_entries_split(parsed_feed)
  end

  web_request(xmlUrl, callback)
end

function M.fetch_all_feeds()
  for line in io.lines(feeds_file) do
    local xmlUrl = utils.get_url(line)
    if (xmlUrl) then
      web_request(xmlUrl, update_feed_line)
    end
  end
end

function M.fetch_feeds_by_category()

  local t = vim.api.nvim_exec([[
    execute ':silent normal vip'
    echo getline("'<", "'>")
  ]], true)

  local category = vim.api.nvim_eval(t)

  for i = 1, #category do
    local line = category[i]
    local xmlUrl = utils.get_url(line)
    if (xmlUrl) then
      web_request(xmlUrl, update_feed_line)
    end
  end

end

function M.import_opml(opml_file)
  print("Importing ", opml_file, "...")

  -- Read all feeds from file
  local feeds = {}
  for line in io.lines(opml_file) do
    local type = line:match("type=\"(.-)\"")
    local link = line:match("xmlUrl=\"(.-)\"")
    local title = line:match("title=\"(.-)\"")
    if not title then
      title = line:match("text=\"(.-)\"")
    end

    if type and title and link then
      feeds[#feeds + 1] = link .. " " .. title
    end
  end

  -- Dump 'em into nvim.rss
  local nvim_rss, err = io.open(feeds_file, "a+")
  if err then
    error(err)
  end
  nvim_rss:write("\n\nOPML IMPORT\n-----\n")
  nvim_rss:write(table.concat(feeds, "\n"))
  nvim_rss:flush()
  nvim_rss:close()
end

function M.view_feed()
  local url = utils.get_url(vim.api.nvim_get_current_line())
  if (not url) then
    error("Invalid url")
  end
  open_entries_split({
    xmlUrl = url,
  })
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
