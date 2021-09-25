local M = {}

local api = vim.api
local loop = vim.loop

local options = {
  feeds_file = "~/.feeds_file",
}

-- Open rss file in new tab
function M.open_feeds_tab()
  vim.cmd("tabnew " .. options.feeds_file)
  -- vim.o.ft = "nvim-rss"
end

-- Refresh content for feed under cursor
function M.fetch_feed()
  local url = api.nvim_get_current_line()
  print("Fetching data for url " .. url)

  local stdout = loop.new_pipe(false)
  local stderr = loop.new_pipe(false)

  handle = vim.loop.spawn("curl", {
    args = { url },
    stdio = { stdout, stderr },
  }, function()
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()
  end)

  loop.read_start(stdout, function(e, r)
    -- TODO
  end)

  loop.read_start(stderr, function(e, r) print("Error stream", e, r) end)
end

function M.setup(user_options) for k, v in pairs(user_options) do options[k] = v end end

return M
