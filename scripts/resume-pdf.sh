#!/usr/bin/env bash
#
# Regenerates public/resume.pdf from src/pages/resume.astro.
#
# The resume page is the single source of truth; this prints it through headless
# Chrome so the PDF picks up the same @media print rules a Cmd+P would. Output is
# real selectable text in a single column, which is what ATS parsers need.
#
# Run after editing the resume: npm run resume:pdf
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
PORT=4399
OUT="$ROOT/public/resume.pdf"

if [ ! -x "$CHROME" ]; then
  echo "error: Google Chrome not found at $CHROME" >&2
  exit 1
fi

cd "$ROOT"

echo "→ Building site"
npm run build >/dev/null

echo "→ Serving dist/ on 127.0.0.1:${PORT}"
python3 -m http.server "$PORT" --directory "$ROOT/dist" --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER_PID=$!
cleanup() { kill "$SERVER_PID" 2>/dev/null || true; }
trap cleanup EXIT

for _ in $(seq 1 40); do
  curl -sf "http://127.0.0.1:$PORT/resume/" -o /dev/null && break
  sleep 0.25
done

echo "→ Printing /resume"
PROFILE="$(mktemp -d)"

# Chrome sometimes lingers after writing the PDF, so cap it rather than hang.
"$CHROME" \
  --headless \
  --disable-gpu \
  --no-first-run \
  --no-pdf-header-footer \
  --user-data-dir="$PROFILE" \
  --virtual-time-budget=15000 \
  --print-to-pdf="$OUT" \
  "http://127.0.0.1:$PORT/resume/" >/dev/null 2>&1 &
CHROME_PID=$!

for _ in $(seq 1 120); do
  kill -0 "$CHROME_PID" 2>/dev/null || break
  sleep 0.5
done
kill "$CHROME_PID" 2>/dev/null || true
wait "$CHROME_PID" 2>/dev/null || true
rm -rf "$PROFILE"

if [ ! -s "$OUT" ]; then
  echo "error: no PDF was written to $OUT" >&2
  exit 1
fi

echo "✓ Wrote $OUT ($(cd "$ROOT" && du -h "$OUT" | cut -f1))"
echo "  public/resume.pdf is copied into dist/ on the next build, so commit it."
exit 0
