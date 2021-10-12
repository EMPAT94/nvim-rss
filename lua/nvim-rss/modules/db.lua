local DB = {}

local sqlite = require("sqlite")
local sqlite_tbl = require("sqlite.tbl")

local feed_table = "feeds"
local feed_schema = {
  link = { -- feed url, also id in atom
    "text",
    primary = true,
    unique = true,
  },
  title = {
    "text",
    required = true,
  },
  subtitle = {
    "text",
  },
  version = { -- is "atom10" or "rss20" etc
    "text",
  },
  format = { -- is "atom" or "rss"
    "text",
    required = true,
  },
  htmlUrl = { -- site url
    "text",
    required = true,
  },
  rights = "text",
  generator = "text",
  author = "text",
}

local entry_table = "entries"
local entry_schema = {
  link = { -- item url
    "text",
    required = true,
    unique = true,
    primary = true,
  },
  title = {
    "text",
    required = true,
  },
  summary = { -- aka content, description et al
    "text",
  },
  feed = {
    type = "text",
    required = true,
    reference = "feeds.link",
  },
  updated = "text",
  updated_parsed = "number",

  -- nvim.rss keys
  seen = {
    "integer", -- timestamp (s) when opened
    required = true,
  },
}

local feeds_db = "nvim.rss.db"

local db = sqlite {
  uri = feeds_db,
  [feed_table] = feed_schema,
  [entry_table] = entry_schema,
}

local function _upsert_feed(feed)

  local feed_row = db:tbl(feed_table):where({
    link = feed.link,
  })

  if (not feed_row) then local e, m = db:tbl(feed_table):insert(feed) end
end

local function _insert_new_entries(parsed_feed)
  local entries = db:tbl(entry_table):get({
    where = {
      feed = parsed_feed.xmlUrl,
    },
    select = { "updated_parsed", "title" },
  })

  local updated = {}
  local titles = {}
  for _, e in ipairs(entries) do
    table.insert(updated, e.updated_parsed)
    table.insert(titles, e.title)
  end

  local last_updated = 0
  if (#updated > 0) then
    table.sort(updated)
    last_updated = updated[#updated]
  end

  local entries = {}
  for _, entry in ipairs(parsed_feed.entries) do
    -- Check whether entry exists in db or not
    local exists = false

    -- Discard all whose updated time is less than that in db
    if (entry.updated_parsed and last_updated >= tonumber(entry.updated_parsed)) then exists = true end

    -- If updated time is not present, compare link
    if (not exists) then
      for _, title in ipairs(titles) do
        if (entry.title == title) then
          do
            exists = true
            break
          end
        end
      end
    end

    if (not exists) then
      table.insert(entries, {
        link = entry.link,
        title = entry.title,
        summary = entry.summary,
        updated = entry.udated,
        updated_parsed = tonumber(entry.updated_parsed),
        feed = parsed_feed.xmlUrl,
        seen = 0,
      })
    end
  end

  if (#entries > 0) then local e, m = db:tbl(entry_table):insert(entries) end

end

function DB.update_feed(parsed_feed)
  if (db:isclose()) then db:open() end

  _upsert_feed({
    link = parsed_feed.xmlUrl,
    title = parsed_feed.feed.title,
    subtitle = parsed_feed.feed.subtitle,
    version = parsed_feed.version,
    format = parsed_feed.format,
    htmlUrl = parsed_feed.feed.link,
    rights = parsed_feed.feed.rights,
    generator = parsed_feed.feed.generator,
    author = parsed_feed.feed.author,
  })

  _insert_new_entries(parsed_feed)

  db:close()
end

function DB.read_feed(feed_link)
  if (db:isclose()) then db:open() end

  local feed_info = db:tbl(feed_table):where({
    link = feed_link,
  })

  local entries = db:tbl(entry_table):get({
    where = {
      feed = feed_link,
    },
  })

  db:close()

  return feed_info, entries
end

function DB.close_if_open()
  if (db:isopen()) then db:close() end
end

return DB
