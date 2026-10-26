#!/usr/bin/env bash
# Deploys the front page and each app's committed dist/ to the server.
# Usage: ./deploy.sh [front|chordtrainer|counterpointer|dicteeineer|harmoneer ...]   (default: all)
# SERVER (ssh host) and WORK (folder holding the app repos) can be overridden from the environment.
set -euo pipefail

SERVER=${SERVER:-server}
WORK=${WORK:-$(cd "$(dirname "$0")/.." && pwd)}
APPS_ROOT=/var/www/html/megacorp1.eu
FRONT_ROOT=/var/www/html/music-trainer.app

# url path -> local repo folder (macOS bash 3.2 has no associative arrays)
repo_of() {
  case $1 in
    chordtrainer|counterpointer|harmoneer) echo "$1" ;;
    dicteeineer) echo dicteeiner ;;
  esac
}

targets=("$@")
[ ${#targets[@]} -eq 0 ] && targets=(front chordtrainer counterpointer dicteeineer harmoneer)

for t in "${targets[@]}"; do
  if [ "$t" = front ]; then
    echo "== front page"
    rsync -a --delete --exclude '.git' --exclude 'nginx' --exclude 'README.md' --exclude 'deploy.sh' \
      "$WORK/music-trainer/" "$SERVER:$FRONT_ROOT/"
    continue
  fi
  repo=$(repo_of "$t")
  [ -z "$repo" ] && { echo "unknown target: $t" >&2; exit 1; }
  dir="$WORK/$repo"
  echo "== $t ($(git -C "$dir" log -1 --format='%h %s'))"
  if [ -n "$(git -C "$dir" status --porcelain -- dist src resources)" ]; then
    echo "   uncommitted changes in $repo; run npm run dist and commit first" >&2
    exit 1
  fi
  rsync -a --delete "$dir/dist/" "$SERVER:$APPS_ROOT/$t/"
done
