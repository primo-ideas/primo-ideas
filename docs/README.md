# Primo Ideas showcase: maintenance

This repo only holds the showcase of the Primo Ideas projects, and the script that records the
game clips. It has no build or CI of its own.

## What lives where

| Place | What it is |
| :-- | :-- |
| `README.md` (this repo) | Project table with links, sources and CI badges, then one section per project with its screenshot. |
| `*.png` (this repo) | One screenshot per project, named after the project (`star-racer.png`, `dronoids.png`, `playdeals.png`, `trading-book.png`, `mythic-essentials.png`). |
| `/var/www/html/index.html` on primo-ideas.xyz | The site's landing page: one card per project, with a clip or a screenshot, tags and a link. Five cards in a row from 1180 px wide (a 1366 px laptop shows them all without scrolling), two below that (an odd last card is centred), one on a phone. |
| `/var/www/html/assets/star-racer.mp4`, `dronoids.mp4` on primo-ideas.xyz | 10 s looping clips of the two games, with their first frame as a WebP poster. How they were recorded: [clips.md](clips.md). |
| `/var/www/html/assets/playdeals.webp`, `trading-book.webp`, `mythic-essentials.webp` on primo-ideas.xyz | The other three cards' screenshots: the PNGs of this repo, scaled to 960 px wide and saved as WebP (quality 80). |
| `tools/record-window.ps1` (this repo) | Records one window to MP4, for the clips ([clips.md](clips.md)). |
| `/var/www/html/favicon.png` on primo-ideas.xyz | The site icon, shared by every page under it. |

## Project names and URLs

| Project | URL | Source repo |
| :-- | :-- | :-- |
| Star Racer | https://primo-ideas.xyz/star-racer/ (`/space-race/` redirects there) | `star-racer` |
| Dronoids | https://primo-ideas.xyz/dronoids/ | `dronoids` |
| Play Deals | https://primo-ideas.xyz/playdeals/ (`/ludeal/` and `wow-trading.live` redirect there; playdeals.io once its DNS is set) | `playdeals-io` (formerly `wow-trading`, `ludeal-io`) |
| Trading Book | https://www.curseforge.com/wow/addons/trading-book | `trading-book` |
| Mythic Essentials | https://github.com/primo-ideas/mythic-essentials/releases/latest (no CurseForge page yet) | `mythic-essentials` |

## Keeping both in sync

When a project is added, renamed, moves to a new URL, gets a new screenshot or changes its CI workflows, update both the README of this repo and the landing page on the server, with the same names, links and descriptions.

The landing page is a single self-contained HTML file (inline CSS and a few lines of JS, no build). To update it:

```bash
scp root@primo-ideas.xyz:/var/www/html/index.html index.html
```

Edit it, then upload it next to the live file and swap it in, so the page is never half written:

```bash
scp index.html root@primo-ideas.xyz:/var/www/html/index.html.new
```

```bash
ssh root@primo-ideas.xyz 'cp -p /var/www/html/index.html /var/www/html/index.html.bak && mv /var/www/html/index.html.new /var/www/html/index.html'
```

Then open https://primo-ideas.xyz/ and check that every card's image and link work.
