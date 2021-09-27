local nvim_rss = require("nvim-rss")

-- TODO check how to test UI changes
describe("nvim-rss test suite", function()
  it("should open feeds tab", function()
    nvim_rss.open_feeds_tab()
  end)

  it ("should fetch feed", function() 
    nvim_rss.fetch_feed()
  end)
end)
