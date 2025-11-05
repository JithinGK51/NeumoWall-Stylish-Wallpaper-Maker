# Assets Directory

This directory contains built-in wallpapers, GIFs, and videos for the NeumoWall app.

## Directory Structure

```
assets/
├── images/          # Static wallpaper images (JPG, PNG, WebP)
├── videos/          # Video wallpapers (MP4, ≤30 seconds) and GIFs (.gif)
├── icons/           # App icons and UI elements
└── data/            # JSON manifest files
```

## Adding Media Files

### Images
- Place image files in `assets/images/`
- Supported formats: JPG, PNG, WebP
- Recommended resolution: 1080x1920 or higher
- Update `assets/data/wallpapers.json` to reference them

### Videos
- Place video files in `assets/videos/`
- **Maximum duration: 30 seconds**
- Supported formats: MP4, MOV
- Recommended resolution: 1080x1920 or higher
- Update `assets/data/wallpapers.json` to reference them

### GIFs
- Place GIF files in `assets/videos/` (or create `assets/gifs/` folder)
- Supported format: GIF
- Recommended resolution: 1080x1920 or higher
- Update `assets/data/wallpapers.json` to reference them

## Example Files to Add

### Images
- `nature_1.jpg`, `nature_2.jpg` - Nature wallpapers
- `abstract_1.jpg`, `abstract_2.jpg` - Abstract wallpapers
- `minimalist_1.jpg` - Minimalist designs
- `dark_1.jpg` - Dark theme wallpapers

### Videos (≤30 seconds)
- `ocean_waves.mp4` - Ocean waves video (15s)
- `abstract_motion.mp4` - Abstract motion video (20s)

### GIFs
- `gradient_animation.gif` - Animated gradient (3s)
- `particles_animation.gif` - Particle animation (4s)

## Updating wallpapers.json

After adding files, update `assets/data/wallpapers.json` with entries like:

```json
{
  "id": "unique_id",
  "title": "Wallpaper Name",
  "description": "Description",
  "type": "image|video|gif",
  "source": "assets/images/filename.jpg",
  "category": "nature|abstract|minimalist|dark|light|gradient",
  "isBuiltIn": true,
  "duration": 15  // For videos/GIFs (in seconds)
}
```

## Notes

- All media files must be properly referenced in `wallpapers.json`
- Video files must be ≤30 seconds to work as wallpapers
- GIFs will animate as live wallpapers
- Images should be optimized for mobile devices

