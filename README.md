# nvim-rss

A simple rss reader for neovim written in lua.

## Project Goals

I aim for it to be similar to the excellent [vnews](https://github.com/danchoi/vnews) and, if you squint hard enough while looking sideways, then perhaps [elfeed](https://github.com/skeeto/elfeed).

Ideally, if you have a bunch of feeds and wish to simply view them in neovim instead of browsers or dedicated apps, then this plugin should help you out.

## Show-case of experimental version

![nvim-rss-sample-photo](./nvim-rss-sample-photo.png)

## Pre-requisites

TODO: Add links, versions and descriptions

1. neovim
2. curl
3. sqlite3
4. feed-parser (from luarocks) (depends on expat)
5. sqlite.lua (from luarocks) (depends on luv)

## Installing (for build testing, not as a plugin yet!)

1. Clone repository
2. luarocks install feedparser and sqlite
3. cd nvim-rss
4. open nvim
5. :source plugin/nvim-rss
6. :OpenRssView
7. Insert a valid rss link eg http://feeds.bbci.co.uk/news/rss.xml
8. Put cursor on the link and call :FetchFeed
9. Enjoy!

## Current Progress and Todos

v0.1 Aim : Simple RSS fetching and viewing
- [x] Fetch & parse feeds
- [x] Setup a database
- [x] Update UI for new feed data
- [ ] Clean up Rssview for better reading
- [ ] Check multiple streams for different data structures
- [ ] Add user interaction to RSS View
- [ ] Release v0.1 (Deadline : 13th Oct 2021)

## Personal Goals

1. Learn lua (I plan to make a few more plugins!)
2. Learn how to make a neovim plugin
3. Contribute to the awesome neovim ecosystem
4. Share some opensource love <3
