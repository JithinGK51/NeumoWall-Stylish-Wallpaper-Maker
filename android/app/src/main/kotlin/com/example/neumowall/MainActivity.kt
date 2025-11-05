package com.example.neumowall

import android.app.WallpaperManager
import android.graphics.BitmapFactory
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
            if (call.method == "setWallpaper") {
                val args = call.arguments as Map<*, *>
                val filePath = args["filePath"] as String
                val wallpaperType = args["wallpaperType"] as String
                
                try {
                    val wallpaperManager = WallpaperManager.getInstance(applicationContext)
                    val bitmap = BitmapFactory.decodeFile(filePath)
                    
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
            } else {
                result.notImplemented()
            }
        }
    }
}
