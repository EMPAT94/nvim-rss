local DB = {}

local sqlite = require("sqlite")

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
  format = { -- is "atom" or "rss"
    "text",
    required = true,
  },
  subtitle = "text",
  version = "text",
  htmlUrl = "text",
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
  summary = "text",
  updated = "text",
  updated_parsed = "number",
  feed = {
    type = "text",
    required = true,
    reference = "feeds.link",
  },

  fetched = "number", -- timestamp of when feed was fetched
}

local db;

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
    updated[#updated + 1] = e.updated_parsed
    titles[#titles + 1] = e.title
  end

  local last_updated = 0
  if (#updated > 0) then
    table.sort(updated)
    last_updated = updated[#updated]
  end

  local new_entries = {}
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
      new_entries[#new_entries + 1] = {
        link = entry.link,
        title = entry.title,
        summary = entry.summary,
        updated = entry.udated,
        updated_parsed = tonumber(entry.updated_parsed),
        feed = parsed_feed.xmlUrl,
        fetched = os.time(),
      }
    end
  end

  if (#new_entries > 0) then local e, m = db:tbl(entry_table):insert(new_entries) end

end

function DB.create(feeds_db)
  db = sqlite {
    uri = feeds_db,
    [feed_table] = feed_schema,
    [entry_table] = entry_schema,
  }
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

function DB.read_entry_stats(feed_link)
  if (db:isclose()) then db:open() end

  local entries = db:tbl(entry_table):get({
    where = {
      feed = feed_link,
    },
  })

  -- Find the count of latest fetched entries
  local fetched = {}
  for _, e in ipairs(entries) do fetched[#fetched + 1] = e.fetched end

  local latest_fetched = 0
  if (next(fetched) ~= nil) then
    table.sort(fetched)
    latest_fetched = fetched[#fetched]
  end

  local latest = 0
  local total = 0
  for _, e in ipairs(entries) do
    if (e.fetched == latest_fetched) then latest = latest + 1 end
    total = total + 1
  end

  db:close()

  return latest, total
end

function DB.close_if_open()
  if (db:isopen()) then db:close() end
end

return DB
