<br />
<h1 align="center">NVIM-RSS</h1>
<p align="center">A simple rss reader for neovim written in lua.</p>
<br />

## Project Goals

I aim for it to be similar to the excellent [vnews](https://github.com/danchoi/vnews) and, if you squint hard enough while looking sideways, then perhaps [elfeed](https://github.com/skeeto/elfeed).

Ideally, if you have a bunch of feeds and simply wish to view the latest entries in neovim instead of browsers or dedicated apps, then this plugin should help you out.

## Showcase (v0.2)

https://user-images.githubusercontent.com/9110181/141071168-ce671cd5-3f9b-4b68-b0d0-bb76abb7a8c5.mp4

## Pre-requisites

1. [neovim](https://neovim.io/)
2. [curl](https://curl.se/) | Usually pre-installed on most systems
3. [sqlite3](https://sqlite.org/index.html) | Usually pre-installed on some systems
4. [feed-parser](https://github.com/slact/lua-feedparser) | `luarocks install feedparser`
5. [sqlite.lua](https://github.com/tami5/sqlite.lua) | `luarocks install sqlite`

## Installation

__Tested on linux, may work on macos. Probably won't work on windows.__

If `vim-plug` then

```vim
Plug 'empat94/nvim-rss'
```

Else your usual way of installing plugins

## Setup

Inside init.lua

```lua
require("nvim-rss").setup({
  feeds_dir = "/home/user/.config/nvim", -- ensure has write permissions
})
```

If using init.vim, wrap the code inside `lua << EOF ... EOF`

## Usage

__By default, no mappings/commands present. All functions are exposed so you may use them as you like!__

* Open RSS file: `open_feeds_tab()`

Opens nvim.rss file where all the feeds are listed. By default `~/nvim.rss`, see [Setup](#Setup) to change default dir.

* Fetch and view a feed: `fetch_feed()`

Pulls updates for the feed under cursor and opens a vertical split to show the entries.

* Fetch feeds by category: `fetch_feeds_by_category()`

Pulls update for all feeds in the category (paragraph) under cursor

* Fetch feeds by visual range: `fetch_selected_feeds()`

Pulls update for all feeds that are selected in visual range

* Fetch all feed: `fetch_all_feeds()`

Fetches data for all feeds in nvim.rss and updates the corresponding counts if nvim.rss is loaded in a buffer.

* View a feed: `view_feed()`

Opens entries for feed under cursor in a vertical split. This does not refreshes data from server, instead pulling stored content from database.

* Import OPML file: `import_opml(opml_file)`

Parses the supplied file, extracts feed links if they exist and dumps them under "OPML Import" inside nvim.rss. They are not added to database unless you explicitly fetch feeds for the links!

---

To use above functions, write the usual mapping or command syntax. Example -

```vim

command! OpenRssView lua require("nvim-rss").open_feeds_tab()

command! FetchFeed lua require("nvim-rss").fetch_feed()

command! FetchAllFeeds lua require("nvim-rss").fetch_all_feeds()

command! FetchFeedsByCategory lua require("nvim-rss").fetch_feeds_by_category()

command! -range FetchSelectedFeeds lua require("nvim-rss").fetch_selected_feeds()

command! ViewFeed lua require("nvim-rss").view_feed()

command! -nargs=1 ImportOpml lua require("nvim-rss").import_opml(<args>)

```

```vim

:OpenRssView

:FetchFeed

:FetchFeedsByCategory

:FetchSelectedFeeds

:FetchAllFeeds

:ViewFeed

:ImportOpml "/home/user/Documents/rss-file.opml"

```

NOTE: The command ImportOpml requires a full path and surrounding quotes.

_Checkout my feeds list [here](https://github.com/EMPAT94/dotfiles/blob/main/nvim/.config/nvim/nvim.rss)_

## Roadmap

v0.1

- [X] Fetch & parse feeds
- [X] Setup a database
- [X] Update UI for new feed data
- [X] Clean up Rssview for better reading
- [X] Check multiple streams for different data structures
- [X] Release v0.1 (Deadline: 13th Oct 2021)

v0.2

- [X] OPML import
- [X] Latest entries feed count
- [X] Refresh all feeds
- [X] View feed (without fetching data from server)
- [X] Release v0.2 (Deadline: 7th Nov 2021)

v0.3

- [ ] Clean database, reset everything
- [ ] Mark favorite feeds, star entries
- [X] Fetch inside category
- [X] Fetch inside visual range (selected lines)
- [ ] Release v0.3 (Deadline: ~3rd Dec 2021~ 7th Jan 2022)

v0.4 and above (Tentative)

- [ ] OPML export
- [ ] Use <Plug> to expose functions
- [ ] Console browser intergation
- [ ] Most viewed, most recent, favorite feeds view
- [ ] Highlight entries (new, read, starred)
- [ ] Windows support

## Personal Goals

1. Learn lua (I plan to make a few more plugins!)
2. Learn how to make a neovim plugin
3. Contribute to the awesome neovim ecosystem
4. Share some opensource love <3
