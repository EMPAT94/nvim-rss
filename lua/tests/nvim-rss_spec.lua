local nvim_rss = require("nvim-rss")

describe("nvim-rss test suite", function()
  it("should open feeds tab", function()
    nvim_rss.open_feeds_tab()
  end)
end)
