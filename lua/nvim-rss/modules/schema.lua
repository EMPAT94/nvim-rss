local M = {}

M.FEED_TABLE = "feeds"

M.ENTRY_TABLE = "entries"

M.FEED_SCHEMA = {
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

M.ENTRY_SCHEMA = {
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

return M
