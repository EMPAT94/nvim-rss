require('busted')
-- require('assertions')
local file_handler = require('../nvim-rss/file_handler')

describe('rss file handler operations', function()
  it('should open an empty file if it does not exist', function() file_handler.read('/tmp/test-file') end)

  it('should open a file', function() end)
end)
