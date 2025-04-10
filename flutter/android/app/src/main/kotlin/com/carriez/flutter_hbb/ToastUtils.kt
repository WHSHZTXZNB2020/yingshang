package com.carriez.flutter_hbb

import android.content.Context
import android.widget.Toast
import android.view.Gravity
import android.util.Log

/**
 * Toast工具类，用于显示各种Toast消息
 */
object ToastUtils {
    private const val TAG = "ToastUtils"
    
    /**
     * 显示已就绪的Toast消息
     */
    fun showReadyToast(context: Context) {
        try {
            val toast = Toast.makeText(
                context,
                Constants.TEXT_READY,
                Toast.LENGTH_SHORT
            )
            toast.setGravity(Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL, 0, 100)
            toast.show()
            Log.d(TAG, "显示已就绪Toast")
        } catch (e: Exception) {
            Log.e(TAG, "显示Toast出错: ${e.message}")
        }
    }
    
    /**
     * 显示自定义消息的Toast
     */
    fun showToast(context: Context, message: String, duration: Int = Toast.LENGTH_SHORT) {
        try {
            val toast = Toast.makeText(context, message, duration)
            toast.setGravity(Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL, 0, 100)
            toast.show()
        } catch (e: Exception) {
            Log.e(TAG, "显示Toast出错: ${e.message}")
        }
    }
} 