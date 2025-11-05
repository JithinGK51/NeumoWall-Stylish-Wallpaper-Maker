package com.example.neumowall

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "neumowall/wallpaper"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setWallpaper" -> {
                    val args = call.arguments as Map<*, *>
                    val filePath = args["filePath"] as String
                    val wallpaperType = args["wallpaperType"] as String
                    val mediaType = args["mediaType"] as? String // "video", "gif", or "image"
                    
                    try {
                        val file = File(filePath)
                        if (!file.exists()) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        
                        val extension = file.extension.lowercase()
                        val isVideo = extension in listOf("mp4", "mov", "avi", "mkv", "webm", "3gp", "flv")
                        val isGif = extension == "gif"
                        
                        // Use live wallpaper for videos and GIFs
                        if ((isVideo || isGif) && mediaType != "image") {
                            setLiveWallpaper(filePath, if (isVideo) "video" else "gif", result)
                        } else {
                            // Use static wallpaper for images or if explicitly requested
                            setStaticWallpaper(filePath, wallpaperType, result)
                        }
                    } catch (e: Exception) {
                        result.error("WALLPAPER_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun setStaticWallpaper(filePath: String, wallpaperType: String, result: MethodChannel.Result) {
        try {
            val wallpaperManager = WallpaperManager.getInstance(applicationContext)
            val bitmap = extractBitmapFromFile(filePath)
            
            if (bitmap != null) {
                when (wallpaperType) {
                    "home" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
                        } else {
                            wallpaperManager.setBitmap(bitmap)
                        }
                        result.success(true)
                    }
                    "lock" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
                        } else {
                            result.success(false) // Lock screen not supported on older Android
                        }
                        result.success(true)
                    }
                    "both" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK)
                        } else {
                            wallpaperManager.setBitmap(bitmap)
                        }
                        result.success(true)
                    }
                    else -> result.success(false)
                }
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            result.error("WALLPAPER_ERROR", e.message, null)
        }
    }
    
    private fun setLiveWallpaper(filePath: String, mediaType: String, result: MethodChannel.Result) {
        try {
            // Save the media path and type to preferences
            WallpaperPreferences.setMediaPath(applicationContext, filePath)
            WallpaperPreferences.setMediaType(applicationContext, mediaType)
            
            // Launch the live wallpaper picker
            val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).apply {
                putExtra(WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT, 
                    ComponentName(applicationContext, AnimatedWallpaperService::class.java))
            }
            
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            // If live wallpaper picker fails, fall back to static
            setStaticWallpaper(filePath, "home", result)
        }
    }

    /**
     * Extracts a bitmap from a file, supporting images, videos, and GIFs.
     * For videos and GIFs, extracts the first frame (used for static wallpapers).
     */
    private fun extractBitmapFromFile(filePath: String): Bitmap? {
        val file = File(filePath)
        if (!file.exists()) {
            return null
        }

        val extension = file.extension.lowercase()
        
        return when (extension) {
            "mp4", "mov", "avi", "mkv", "webm", "3gp", "flv" -> {
                // Extract first frame from video
                extractFrameFromVideo(filePath)
            }
            "gif" -> {
                // Extract first frame from GIF
                extractFrameFromGif(filePath)
            }
            else -> {
                // Try to decode as image (jpg, png, webp, etc.)
                BitmapFactory.decodeFile(filePath)
            }
        }
    }

    /**
     * Extracts the first frame from a video file.
     */
    private fun extractFrameFromVideo(videoPath: String): Bitmap? {
        var retriever: MediaMetadataRetriever? = null
        try {
            retriever = MediaMetadataRetriever()
            retriever.setDataSource(videoPath)
            return retriever.frameAtTime
        } catch (e: Exception) {
            return null
        } finally {
            retriever?.release()
        }
    }

    /**
     * Extracts the first frame from a GIF file.
     * Android's BitmapFactory.decodeFile() will decode the first frame of a GIF.
     */
    private fun extractFrameFromGif(gifPath: String): Bitmap? {
        return try {
            BitmapFactory.decodeFile(gifPath)
        } catch (e: Exception) {
            null
        }
    }
}
