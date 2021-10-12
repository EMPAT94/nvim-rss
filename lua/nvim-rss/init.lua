-- TODO For dev, remove later
function _G.prints(...)
  local objects = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  print(table.concat(objects, "\n"))
end

-- TODO rockspec ? Check how to install module as dependency
local feedparser = require("feedparser")
local db = require("nvim-rss.modules.db")

-- TODO Split code into proper functions and modules
-- TODO Move to constants.lua maybe ?
local cmd = vim.cmd
local api = vim.api
local spawn = vim.loop.spawn
local new_pipe = vim.loop.new_pipe
local wrap = vim.schedule_wrap
local curl = "curl"

local options = {
  feeds_dir = "~",
  verbose = false,
}

local feeds_file = "nvim.rss"

local function handle_error(err, str)
  db.close_if_open()
  error(err, str)
end

local function sanitize(text)
  if (not text) then return end
  local str = tostring(text):gsub("<.->", "") -- Remove markup
  local t = {}
  for s in string.gmatch(str, "([^\n]+)") do table.insert(t, s) end
  return t
end

local function is_url(str)
  local starts_with_http = str:sub(1, 4) == "http"
  local has_no_spaces = not str:match("%s")
  return starts_with_http and has_no_spaces
end

local function _insert_entries_into_buffer(entries)
  for i, entry in ipairs(entries) do
    vim.fn.append(vim.fn.line("$"), "")
    vim.fn.append(vim.fn.line("$"), "")
    vim.fn.append(vim.fn.line("$"), entry.title)
    vim.fn.append(vim.fn.line("$"), "------------------------")
    vim.fn.append(vim.fn.line("$"), entry.link)
    vim.fn.append(vim.fn.line("$"), "")
    if (entry.summary) then vim.fn.append(vim.fn.line("$"), sanitize(entry.summary)) end
  end
  cmd("0")
end

local function _insert_feed_info_into_buffer(feed_info)
  cmd("normal o " .. feed_info.title)
  cmd("center")
  cmd("normal o")
  cmd("normal o " .. feed_info.htmlUrl)
  cmd("center")
  cmd("normal o")
  if (feed_info.subtitle) then
    cmd("normal o " .. feed_info.subtitle)
    cmd("center")
  end
  cmd("normal o")

  if (options.verbose) then
    cmd("normal o VERSION : " .. feed_info.version)
    cmd("normal o FORMAT : " .. feed_info.format)
    cmd("normal o UPDATED : " .. feed_info.updated)
    cmd("normal o RIGHTS : " .. feed_info.rights)
    cmd("normal o GENERATOR : " .. feed_info.generator)
    cmd("normal o AUTHOR : " .. feed_info.author)
  end

  cmd("normal o ========================================")
  cmd("center")
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

  _insert_feed_info_into_buffer(feed_info)

  _insert_entries_into_buffer(entries)
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
  cmd("tabnew " .. options.feeds_dir .. "/" .. feeds_file)
end

-- Refresh content for feed under cursor
function M.fetch_feed()
  local xmlUrl = api.nvim_get_current_line()

  if (not is_url(xmlUrl)) then handle_error("Line under cursor not a valid url") end

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

function M.setup(user_options)
  for k, v in pairs(user_options) do options[k] = v end
end

return M
