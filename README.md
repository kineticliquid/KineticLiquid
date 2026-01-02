# KineticLiquid

Short project description.

## Images in this repository

This repository uses two main images which should be placed under:

- `assets/images/architecture.png` — architecture diagram (Image 1).
- `assets/images/hero.jpg` — hero banner (Image 2).

Recommended file layout:

```
assets/images/architecture.png
assets/images/architecture@1600.webp
assets/images/architecture@800.webp
assets/images/hero.jpg
assets/images/hero@1920.webp
assets/images/hero@1200.webp
```

## Quick usage examples

Insert images in Markdown (GitHub will render PNG/JPEG automatically):

![Architecture diagram](assets/images/architecture.png)

For better web performance use the <picture> element with WebP fallbacks:

<picture>
  <source srcset="assets/images/architecture@1600.webp" type="image/webp">
  <source srcset="assets/images/architecture@800.webp" type="image/webp">
  <img src="assets/images/architecture.png" alt="Architecture diagram" style="max-width:100%;height:auto;">
</picture>

---

## Hero / banner

<picture>
  <source srcset="assets/images/hero@1920.webp" type="image/webp">
  <source srcset="assets/images/hero@1200.webp" type="image/webp">
  <img src="assets/images/hero.jpg" alt="Liquid. Looped. Scalable." style="width:100%;height:auto;">
</picture>

---

## add-images.sh script

You can add a helper script to the repository root called `add-images.sh` to copy image files into `assets/images` and create WebP/resized versions when ImageMagick is available. Example usage is below; the script itself is kept as a separate file (not included here).

Example usage:

```bash
# Make it executable: chmod +x add-images.sh
./add-images.sh /path/to/architecture.png /path/to/hero.jpg
git add assets/images/*
git commit -m "Add architecture diagram and hero image"
git push origin main
```

If your images are larger than 100 MB, use Git LFS:

```bash
git lfs install
git lfs track "assets/images/*"
git add .gitattributes
git add assets/images/*
git commit -m "Track images with LFS"
git push origin main
```

## Recommendations

- Use short, semantic filenames: `architecture.png`, `hero.jpg`.
- Add proper `alt` text for accessibility.
- Keep editable source files in `assets/source/` if you plan to iterate on designs.
- Use ImageMagick (`magick`) or `cwebp` to generate optimized WebP versions for the web.

---

If you want, I can also:
- add the `assets/images/*` files to the repository (you will need to provide the source images or confirm you want me to upload them),
- add a ready-to-run `add-images.sh` script to the repo and commit it,
- or create image-optimized WebP/resized files and commit them for you.

Commit message used: "Update README: add image usage and assets instructions"