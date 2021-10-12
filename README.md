# nvim-rss

A simple rss reader for neovim written in lua.

## Project Goals

I aim for it to be similar to the excellent [vnews](https://github.com/danchoi/vnews) and, if you squint hard enough while looking sideways, then perhaps [elfeed](https://github.com/skeeto/elfeed).

Ideally, if you have a bunch of feeds and wish to simply view them in neovim instead of browsers or dedicated apps, then this plugin should help you out.

## Show-case of experimental version

![nvim-rss-sample-photo](./nvim-rss-sample-photo.png)

## Pre-requisites (installation cmd for yay)

1. [neovim](https://neovim.io/) | `yay -S neovim`
2. [curl](https://curl.se/) | `yay -S curl` | Usually pre-installed on most systems
3. [sqlite3](https://sqlite.org/index.html) | `yay -S sqlite3` | Usually pre-installed on some systems
4. [feed-parser](https://github.com/slact/lua-feedparser) | `luarocks install feedparser`
5. [sqlite.lua](https://github.com/tami5/sqlite.lua) | `luarocks install sqlite`

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

## Roadmap

v0.1

- [x] Fetch & parse feeds
- [x] Setup a database
- [x] Update UI for new feed data
- [x] Clean up Rssview for better reading
- [x] Check multiple streams for different data structures
- [ ] Release v0.1 (Deadline : 13th Oct 2021)

v0.2

- [ ] OPML import/export
- [ ] Unread feed highlight
- [ ] Total and unread entries count
- [ ] Refreash all feeds function

> v0.3 (Tentative)

- [ ] Mark favorite entries
- [ ] Console browser intergation
- [ ] Most viewed, most recent feeds view

## Personal Goals

1. Learn lua (I plan to make a few more plugins!)
2. Learn how to make a neovim plugin
3. Contribute to the awesome neovim ecosystem
4. Share some opensource love <3
