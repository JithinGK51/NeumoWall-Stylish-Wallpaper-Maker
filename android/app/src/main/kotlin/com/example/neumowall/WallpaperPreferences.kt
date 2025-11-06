package com.example.neumowall

import android.content.Context
import android.content.SharedPreferences

object WallpaperPreferences {
    private const val PREFS_NAME = "wallpaper_prefs"
    private const val KEY_MEDIA_PATH = "media_path"
    private const val KEY_MEDIA_TYPE = "media_type"
    
    private fun getPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }
    
    fun setMediaPath(context: Context, path: String) {
        getPreferences(context).edit().putString(KEY_MEDIA_PATH, path).apply()
    }
    
    fun getMediaPath(context: Context): String? {
        return getPreferences(context).getString(KEY_MEDIA_PATH, null)
    }
    
    fun setMediaType(context: Context, type: String) {
        getPreferences(context).edit().putString(KEY_MEDIA_TYPE, type).apply()
    }
    
    fun getMediaType(context: Context): String? {
        return getPreferences(context).getString(KEY_MEDIA_TYPE, null)
    }
    
    fun clear(context: Context) {
        getPreferences(context).edit().clear().apply()
    }
}

