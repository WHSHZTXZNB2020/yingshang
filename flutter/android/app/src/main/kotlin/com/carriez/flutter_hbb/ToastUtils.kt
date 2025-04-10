package com.carriez.flutter_hbb

import android.content.Context
import android.widget.Toast
import android.view.Gravity
import android.util.Log
import android.view.LayoutInflater
import android.widget.TextView
import android.view.View
import android.graphics.Color
import android.widget.LinearLayout
import android.graphics.drawable.GradientDrawable

/**
 * Toast工具类，用于显示纯文本黑色背景Toast，无图标
 */
object ToastUtils {
    private const val TAG = "ToastUtils"
    
    /**
     * 显示已就绪的Toast消息（黑色背景无图标）
     */
    fun showReadyToast(context: Context) {
        try {
            // 创建自定义黑色背景Toast
            createCustomBlackToast(context, Constants.TEXT_READY, Toast.LENGTH_SHORT)
        } catch (e: Exception) {
            Log.e(TAG, "显示已就绪Toast出错: ${e.message}")
        }
    }
    
    /**
     * 显示自定义消息的Toast（黑色背景无图标）
     */
    fun showToast(context: Context, message: String, duration: Int = Toast.LENGTH_SHORT) {
        try {
            // 创建自定义黑色背景Toast
            createCustomBlackToast(context, message, duration)
        } catch (e: Exception) {
            Log.e(TAG, "显示自定义Toast出错: ${e.message}")
        }
    }
    
    /**
     * 创建自定义黑色背景Toast，完全没有图标
     */
    private fun createCustomBlackToast(context: Context, message: String, duration: Int) {
        try {
            // 创建一个新的LinearLayout作为根容器
            val layout = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(40, 25, 40, 25)
                
                // 创建圆角矩形背景
                val shape = GradientDrawable()
                shape.cornerRadius = 25f // 圆角半径
                shape.setColor(Color.parseColor("#CC000000")) // 黑色背景，80%不透明度
                background = shape
            }
            
            // 创建TextView显示消息
            val textView = TextView(context).apply {
                text = message
                textSize = 14f
                setTextColor(Color.WHITE)
            }
            
            // 添加TextView到容器
            layout.addView(textView)
            
            // 创建Toast并设置自定义视图
            val toast = Toast(context).apply {
                setGravity(Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL, 0, 100)
                this.duration = duration
                view = layout
            }
            
            // 显示Toast
            toast.show()
            Log.d(TAG, "显示黑色背景Toast: $message")
        } catch (e: Exception) {
            // 如果自定义视图失败，使用普通Toast作为备选
            Log.e(TAG, "创建自定义Toast失败: ${e.message}")
            
            // 备选方案：尝试使用普通Toast
            val toast = Toast.makeText(context, message, duration)
            toast.setGravity(Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL, 0, 100)
            toast.show()
        }
    }
} 