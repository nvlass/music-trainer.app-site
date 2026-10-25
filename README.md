# music-trainer.app

Front page and nginx config for [music-trainer.app](https://music-trainer.app), which hosts three free, browser-based apps:

- [Chord Trainer](https://github.com/nvlass/chordtrainer) at `/chordtrainer/`
- [Counterpointer](https://github.com/nvlass/counterpointer) at `/counterpointer/`
- [Dicteeineer](https://github.com/nvlass/dicteeineer) at `/dicteeineer/`

The front page is a single static `index.html` + `style.css` (English and Greek, picked from the browser language, with a toggle). No build step.

## Server layout

| URL | Folder |
|---|---|
| `/` | `/var/www/html/music-trainer.app/` (this repo) |
| `/chordtrainer/` | `/var/www/html/megacorp1.eu/chordtrainer/` |
| `/counterpointer/` | `/var/www/html/megacorp1.eu/counterpointer/` |
| `/dicteeineer/` | `/var/www/html/megacorp1.eu/dicteeineer/` |

The apps use relative paths throughout, so they work under a path without changes. Each one's service worker is scoped to its own folder.

## Deploy

Front page:

```sh
rsync -a --delete --exclude '.git' --exclude 'nginx' --exclude 'README.md' ./ server:/var/www/html/music-trainer.app/
```

nginx:

```sh
sudo mkdir -p /var/www/html/music-trainer.app
sudo cp nginx/music-trainer.app.conf /etc/nginx/sites-available/music-trainer.app
sudo ln -s /etc/nginx/sites-available/music-trainer.app /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d music-trainer.app -d www.music-trainer.app
```

Everything is served `no-cache` (the browser revalidates, so deploys show up at once) except the piano samples, which never change.

Moving from the old subdomains: progress is stored per origin (IndexedDB), so it doesn't carry over to the new domain. Users can export stats from the old address (Chord Trainer has export/import).
