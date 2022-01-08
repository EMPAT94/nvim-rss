local M = {}

local sqlite = require("sqlite")

local S = require("nvim-rss.modules.schema")

local db;

local function _upsert_feed(feed)
  local feed_row = db:tbl(S.FEED_TABLE):where({
    link = feed.link,
  })

  if (not feed_row) then
    local e, m = db:with_open(function()
      return db:tbl(S.FEED_TABLE):insert(feed)
    end)
  end
end

local function _insert_new_entries(parsed_feed)
  local entries = db:tbl(S.ENTRY_TABLE):get({
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
    if (entry.updated_parsed and last_updated >= tonumber(entry.updated_parsed)) then
      exists = true
    end

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

  if (#new_entries > 0) then
    local e, m = db:tbl(S.ENTRY_TABLE):insert(new_entries)
  end

end

function M.create(feeds_db)
  db = sqlite {
    uri = feeds_db,
    [S.FEED_TABLE] = S.FEED_SCHEMA,
    [S.ENTRY_TABLE] = S.ENTRY_SCHEMA,
  }
end

function M.update_feed(parsed_feed)

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

end

function M.read_feed(feed_link)

  local feed_info = db:tbl(S.FEED_TABLE):where({
    link = feed_link,
  })

  local entries = db:tbl(S.ENTRY_TABLE):get({
    where = {
      feed = feed_link,
    },
  })

  return feed_info, entries
end

function M.read_entry_stats(feed_link)

  local entries = db:tbl(S.ENTRY_TABLE):get({
    where = {
      feed = feed_link,
    },
  })

  -- Find the count of latest fetched entries
  local fetched = {}
  for _, e in ipairs(entries) do
    fetched[#fetched + 1] = e.fetched
  end

  local latest_fetched = 0
  if (next(fetched) ~= nil) then
    table.sort(fetched)
    latest_fetched = fetched[#fetched]
  end

  local latest = 0
  local total = 0
  for _, e in ipairs(entries) do
    if (e.fetched == latest_fetched) then
      latest = latest + 1
    end
    total = total + 1
  end

  return latest, total, latest_fetched
end

function M.remove_entries(feed_link)
  return db:tbl(S.ENTRY_TABLE):remove({
    feed = feed_link,
  })
end

function M.truncate_tables()
  db:tbl(S.ENTRY_TABLE):remove()
  db:tbl(S.FEED_TABLE):remove()
end

return M
