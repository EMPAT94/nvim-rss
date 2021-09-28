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
    required = true,
  },
  version = { -- is "atom10" or "rss20" etc
    "text",
    required = true,
  },
  format = { -- is "atom" or "rss"
    "text",
    required = true,
  },
  htmlUrl = { -- site url
    "text",
    required = true,
  },
  updated = {
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
    required = true,
  },
  updated = {
    "text",
    required = true,
  },
  feed = {
    type = "text",
    required = true,
    reference = "feeds.link",
  },

  -- nvim.rss keys
  seen = {
    "integer", -- timestamp (s) when opened
    required = true,
  },
}

-- TODO
-- dir will be user editable
-- better table names preferable
local database_path = "nvim.rss.db"

local db = sqlite {
  uri = database_path,
  [feed_table] = feed_schema,
  [entry_table] = entry_schema,
}

function DB.update_feed(parsed_feed)
  if (db:isclose()) then db:open() end

  local feed = {
    link = parsed_feed.xmlUrl,
    title = parsed_feed.feed.title,
    subtitle = parsed_feed.feed.subtitle,
    version = parsed_feed.version,
    format = parsed_feed.format,
    htmlUrl = parsed_feed.feed.link,
    updated = parsed_feed.feed.updated,
    rights = parsed_feed.feed.rights,
    generator = parsed_feed.feed.generator,
    author = parsed_feed.feed.author,
  }

  local er, ms = db:insert(feed_table, feed)

  local entries = {}
  for _, entry in ipairs(parsed_feed.entries) do
    table.insert(entries, {
      link = entry.link,
      title = entry.title,
      summary = entry.summary,
      updated = entry.updated,
      feed = parsed_feed.xmlUrl,
      seen = 0
    })
  end

  local e, m = db:insert(entry_table, entries)

  db:close()
end

return DB
