# Primo Ideas showcase: maintenance

This repo only holds the showcase of the Primo Ideas projects. It has no code, build or CI of its own.

## What lives where

| Place | What it is |
| :-- | :-- |
| `README.md` (this repo) | Project table with links, sources and CI badges, then one section per project with its screenshot. |
| `*.png` (this repo) | One screenshot per project, named after the project (`star-racer.png`, `dronoids.png`, `ludeal.png`, `trading-book.png`). |
| `/var/www/html/index.html` on primo-ideas.xyz | The site's landing page: one card per project, with a screenshot, tags and a link. |
| `/var/www/html/assets/*.webp` on primo-ideas.xyz | The landing page's screenshots: the PNGs of this repo, scaled to 960 px wide and saved as WebP (quality 80). |
| `/var/www/html/favicon.png` on primo-ideas.xyz | The site icon, shared by every page under it. |

## Project names and URLs

| Project | URL | Source repo |
| :-- | :-- | :-- |
| Star Racer | https://primo-ideas.xyz/star-racer/ (`/space-race/` redirects there) | `star-racer` |
| Dronoids | https://primo-ideas.xyz/dronoids/ | `dronoids` |
| Ludeal | https://primo-ideas.xyz/ludeal/ (`wow-trading.live` redirects there) | `wow-trading` |
| Trading Book | https://www.curseforge.com/wow/addons/trading-book | `trading-book` |

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
