# Animated Wallpaper Implementation

## ✅ Implementation Complete

The app now supports **animated wallpapers** for videos and GIFs! They will play as live wallpapers instead of just extracting the first frame.

## 🎯 How It Works

### For Videos
- Videos are set as **Live Wallpapers** that play continuously
- Uses Android `MediaPlayer` to play the video in a loop
- Automatically pauses when screen is off (battery efficient)
- Resumes when screen is on

### For GIFs
- GIFs are set as **Live Wallpapers** with full animation
- Uses Android `Movie` class to decode and animate GIF frames
- Plays at ~60 FPS for smooth animation
- Automatically loops

### For Static Images
- Regular images work as before (static wallpapers)
- Can be set to Home, Lock, or Both screens

## 📱 User Experience

When setting a video or GIF wallpaper:
1. The app opens the **Android Live Wallpaper Picker**
2. User selects the wallpaper from the picker
3. User can preview and set it
4. The wallpaper plays automatically

**Note**: This requires user interaction to set the live wallpaper (Android security requirement).

## 🔧 Technical Implementation

### Files Created

1. **VideoWallpaperEngine.kt**
   - Handles video playback in wallpaper
   - Uses MediaPlayer for video rendering
   - Manages playback lifecycle

2. **GifWallpaperEngine.kt**
   - Handles GIF animation in wallpaper
   - Uses Movie class to decode GIF frames
   - Renders frames at 60 FPS

3. **AnimatedWallpaperService.kt**
   - Main service that creates the appropriate engine
   - Determines whether to use video or GIF engine
   - Manages wallpaper lifecycle

4. **WallpaperPreferences.kt**
   - Stores media path and type
   - Used to pass data to wallpaper service

### Files Modified

1. **MainActivity.kt**
   - Detects video/GIF files
   - Routes to live wallpaper or static wallpaper
   - Launches live wallpaper picker

2. **wallpaper_service.dart**
   - Passes media type to native code
   - Determines if media should be animated

3. **AndroidManifest.xml**
   - Added Live Wallpaper service
   - Added BIND_WALLPAPER permission
   - Added wallpaper.xml metadata

4. **wallpaper.xml** (new)
   - Live wallpaper metadata configuration

## ⚙️ Configuration

### AndroidManifest.xml
- Added `BIND_WALLPAPER` permission
- Registered `AnimatedWallpaperService`
- Added wallpaper metadata

### Service Registration
The live wallpaper service is registered in AndroidManifest.xml and will appear in the system wallpaper picker.

## 🎨 Features

### Video Wallpapers
- ✅ Continuous playback (looping)
- ✅ Auto-pause when screen off
- ✅ Auto-resume when screen on
- ✅ Supports: MP4, MOV, AVI, MKV, WebM, 3GP, FLV

### GIF Wallpapers
- ✅ Full animation playback
- ✅ Smooth 60 FPS rendering
- ✅ Auto-looping
- ✅ Proper scaling to fit screen

### Static Images
- ✅ Works as before
- ✅ Can be cropped
- ✅ Home/Lock/Both support

## 🚀 Usage

1. Select a video or GIF in the app
2. Tap "Set Wallpaper"
3. Choose Home/Lock/Both (for static) or Live Wallpaper (for video/GIF)
4. System wallpaper picker opens
5. Select and set the wallpaper
6. Video/GIF plays automatically!

## ⚠️ Limitations

1. **User Interaction Required**: Android requires user to manually select the live wallpaper from the system picker (security requirement)

2. **Lock Screen**: Some devices may not support live wallpapers on lock screen - depends on manufacturer

3. **Battery**: Live wallpapers use more battery than static, but the implementation auto-pauses when screen is off

4. **Device Compatibility**: Some older devices or custom ROMs may have limited live wallpaper support

## 🔄 Fallback Behavior

If live wallpaper cannot be set:
- Automatically falls back to static wallpaper (first frame)
- User still gets a wallpaper, just not animated

## 📝 Notes

- The `Movie` class used for GIFs is deprecated but still works on all Android versions
- MediaPlayer is the standard Android video player
- All wallpapers are set through the system wallpaper picker for security
- The implementation is optimized for battery life

## 🧪 Testing

To test:
1. Add a video file to the app
2. Try setting it as wallpaper
3. Verify live wallpaper picker opens
4. Set the wallpaper
5. Verify video plays on home screen
6. Lock and unlock device - verify video pauses/resumes

