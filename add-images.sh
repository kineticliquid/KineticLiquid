#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./add-images.sh /path/to/architecture.png /path/to/hero.jpg
# Copies files into assets/images, creates WebP/resized versions when ImageMagick is available.

SRC_ARCH="${1:-}"
SRC_HERO="${2:-}"
DST_DIR="assets/images"

if [ -z "$SRC_ARCH" ] || [ -z "$SRC_HERO" ]; then
  echo "Usage: $0 /path/to/architecture.png /path/to/hero.jpg"
  exit 2
fi

mkdir -p "$DST_DIR"

ARCH_NAME="architecture.png"
HERO_NAME="hero.jpg"

cp "$SRC_ARCH" "$DST_DIR/$ARCH_NAME"
cp "$SRC_HERO" "$DST_DIR/$HERO_NAME"

# If ImageMagick (magick) available, produce resized/webp variants
if command -v magick >/dev/null 2>&1; then
  echo "ImageMagick found — creating resized and webp versions..."
  magick "$DST_DIR/$ARCH_NAME" -strip -quality 88 -resize 1600x "$DST_DIR/architecture@1600.webp"
  magick "$DST_DIR/$ARCH_NAME" -strip -quality 82 -resize 800x "$DST_DIR/architecture@800.webp"
  magick "$DST_DIR/$HERO_NAME" -strip -quality 88 -resize 1920x "$DST_DIR/hero@1920.webp"
  magick "$DST_DIR/$HERO_NAME" -strip -quality 82 -resize 1200x "$DST_DIR/hero@1200.webp"
else
  echo "ImageMagick not found — skipping conversions. Install ImageMagick to auto-create webp/resized images."
fi

echo "Files placed in $DST_DIR:"
ls -1 "$DST_DIR"
echo
echo "Next: git add, commit and push the files (see README snippet)"
