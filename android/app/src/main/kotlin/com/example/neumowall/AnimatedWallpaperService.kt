package com.example.neumowall

import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import java.io.File

class AnimatedWallpaperService : WallpaperService() {
    
    companion object {
        const val EXTRA_MEDIA_PATH = "media_path"
        const val EXTRA_MEDIA_TYPE = "media_type" // "video" or "gif"
    }
    
    private var mediaPath: String? = null
    private var mediaType: String? = null
    
    override fun onCreateEngine(): Engine {
        // Get the media path and type from shared preferences or intent
        mediaPath = WallpaperPreferences.getMediaPath(applicationContext)
        mediaType = WallpaperPreferences.getMediaType(applicationContext)
        
        return when (mediaType) {
            "video" -> {
                if (mediaPath != null && File(mediaPath!!).exists()) {
                    VideoWallpaperEngine(mediaPath!!)
                } else {
                    EmptyWallpaperEngine()
                }
            }
            "gif" -> {
                if (mediaPath != null && File(mediaPath!!).exists()) {
                    GifWallpaperEngine(mediaPath!!)
                } else {
                    EmptyWallpaperEngine()
                }
            }
            else -> EmptyWallpaperEngine()
        }
    }
    
    // Video wallpaper engine as inner class
    private inner class VideoWallpaperEngine(private val videoPath: String) : Engine() {
        private var mediaPlayer: android.media.MediaPlayer? = null
        private var isVisible = false
        private var wasPlaying = false
        
        override fun onCreate(surfaceHolder: SurfaceHolder) {
            super.onCreate(surfaceHolder)
            surfaceHolder.setFormat(android.graphics.PixelFormat.RGBA_8888)
            initializePlayer(surfaceHolder)
        }
        
        private fun initializePlayer(surfaceHolder: SurfaceHolder) {
            try {
                mediaPlayer = android.media.MediaPlayer().apply {
                    setDataSource(videoPath)
                    setDisplay(surfaceHolder)
                    isLooping = true
                    setOnPreparedListener {
                        if (isVisible) {
                            start()
                            wasPlaying = true
                        }
                    }
                    setOnErrorListener { _, _, _ -> false }
                    setOnCompletionListener {
                        if (isVisible) {
                            seekTo(0)
                            start()
                        }
                    }
                    prepareAsync()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        
        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)
            isVisible = visible
            val player = mediaPlayer ?: return
            
            if (visible) {
                if (wasPlaying || !player.isPlaying) {
                    player.start()
                    wasPlaying = true
                }
            } else {
                if (player.isPlaying) {
                    player.pause()
                    wasPlaying = false
                }
            }
        }
        
        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            super.onSurfaceDestroyed(holder)
            releasePlayer()
        }
        
        override fun onDestroy() {
            super.onDestroy()
            releasePlayer()
        }
        
        private fun releasePlayer() {
            mediaPlayer?.release()
            mediaPlayer = null
            wasPlaying = false
        }
    }
    
    // GIF wallpaper engine as inner class
    private inner class GifWallpaperEngine(private val gifPath: String) : Engine() {
        private var movie: android.graphics.Movie? = null
        private var surfaceHolder: SurfaceHolder? = null
        private val handler = android.os.Handler(android.os.Looper.getMainLooper())
        private var isVisible = false
        private var movieStart = 0L
        private val paint = android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG)
        
        private val frameRunnable = object : Runnable {
            override fun run() {
                if (isVisible && movie != null) {
                    drawFrame()
                    handler.postDelayed(this, 16) // ~60 FPS
                }
            }
        }
        
        override fun onCreate(surfaceHolder: SurfaceHolder) {
            super.onCreate(surfaceHolder)
            this.surfaceHolder = surfaceHolder
            loadGif()
        }
        
        private fun loadGif() {
            try {
                val inputStream = java.io.FileInputStream(gifPath)
                movie = android.graphics.Movie.decodeStream(inputStream)
                inputStream.close()
                movieStart = android.os.SystemClock.uptimeMillis()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        
        private fun drawFrame() {
            val holder = surfaceHolder ?: return
            val canvas = holder.lockCanvas() ?: return
            
            try {
                val movie = this.movie ?: return
                val now = android.os.SystemClock.uptimeMillis()
                var relTime = ((now - movieStart) % movie.duration()).toInt()
                
                movie.setTime(relTime)
                
                // Scale to fit screen
                val scaleX = canvas.width.toFloat() / movie.width()
                val scaleY = canvas.height.toFloat() / movie.height()
                val scale = scaleX.coerceAtMost(scaleY)
                
                canvas.save()
                canvas.scale(scale, scale)
                canvas.translate(
                    (canvas.width / scale - movie.width()) / 2f,
                    (canvas.height / scale - movie.height()) / 2f
                )
                
                movie.draw(canvas, 0f, 0f, paint)
                canvas.restore()
            } finally {
                holder.unlockCanvasAndPost(canvas)
            }
        }
        
        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)
            isVisible = visible
            if (visible) {
                movieStart = android.os.SystemClock.uptimeMillis()
                handler.post(frameRunnable)
            } else {
                handler.removeCallbacks(frameRunnable)
            }
        }
        
        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            super.onSurfaceDestroyed(holder)
            handler.removeCallbacks(frameRunnable)
            movie = null
        }
        
        override fun onDestroy() {
            super.onDestroy()
            handler.removeCallbacks(frameRunnable)
            movie = null
        }
    }
    
    // Empty engine as fallback
    private inner class EmptyWallpaperEngine : Engine() {
        override fun onSurfaceCreated(holder: SurfaceHolder?) {
            super.onSurfaceCreated(holder)
        }
    }
}
