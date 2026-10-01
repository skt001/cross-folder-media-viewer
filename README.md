# Cross-Folder Media Viewer

A static web viewer for browsing images and videos kept across multiple folders, filterable by folder name. Styling is handled by [Simple.css](https://simplecss.org/) and follows the OS light/dark setting.

[日本語版はこちら](README.ja.md)

## How it works

1. Place the files from this repository in the folder that holds your images and videos.
2. Double-click `update.bat` to build `media.json`, an index of every image/video found (dotfiles and dot-folders are skipped). Re-run it whenever files are added or removed.
3. Serve that folder over HTTP (e.g. a NAS's static web server).
4. Open `view.html` in a browser.

Most browsers can't read `media.json` over `file://`; open the folder over HTTP instead.

## Features

- Recursively indexes images and videos under the folder.
- Filter by type (image/video), by folder, and by file extension (every extension starts checked; uncheck one to hide files your browser can't render).
- Galleries over 300 items show a warning instead of rendering by default; a button lets you force-show them anyway.
- `update.bat` keeps its window open (pause on exit) and writes its output to `update.log`.

## Files

| File | Role |
|---|---|
| `view.html` | The viewer: markup and logic |
| `update.bat` | Entry point; runs `update.ps1` and pauses so you can read the output |
| `update.ps1` | Builds `media.json` |
| `media.json` | Generated index (path, kind, extension); created by `update.bat`, not included in this repository |
| `update.log` | Generated log from the last `update.bat` run |
| `simple.min.css` | Styling; not included, see below |

## Getting Simple.css

`view.html` expects a `simple.min.css` file next to it, but it is not included in this repository. Either:

- Download it from the [Simple.css repository](https://github.com/kevquirk/simple.css) and place it next to `view.html`, or
- Change the `<link>` tag in `view.html` to point at the CDN instead: `https://cdn.simplecss.org/simple.min.css`.

## License

MIT — see [LICENSE](LICENSE).

