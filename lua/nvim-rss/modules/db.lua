local DB = {}

-- TODO 
-- dir will be user editable
-- better table names preferable
local database_path = "nvim.rss.db"
local feed_list_table = "feed_list"
local sqlite = require("sqlite")
local db = sqlite {
  uri = database_path,
  [feed_list_table] = {
    id = true, -- integer, primary
    title = "text",
    description = "text",
    htmlUrl = "text",
    xmlUrl = "text",
    updated = "text",
    lastestEntry = "text",
    lastReadEntry = "text",
    category = "text",
  },
}

local spawn = vim.loop.spawn
local new_pipe = vim.loop.new_pipe
local wrap = vim.schedule_wrap

-- INTERNAL FUNCTIONS START (defined by '_' underscore)

function DB._verify_feed_list_exists()
  if (not db:isopen()) then
    db:open()
    if (not db:exists(feed_list_table)) then error("There was an error creating main table!") end
    db:close()
  end
end

function DB._update_feed_list_table()
end

-- INTERNAL FUNCTIONS END

function DB.create_feed_table(table_name)
end

function DB.remove_feed_table()
end

function DB.add_feed()
end

function DB.add_feeds()
end

function DB.update_feed()
end

function DB.remove_feed()
end

function DB.read_feed_by_id()
end

function DB.read_latest_feed()
end

return DB
