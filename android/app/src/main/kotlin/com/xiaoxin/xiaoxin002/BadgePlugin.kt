package com.xiaoxin.xiaoxin002

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import me.leolin.shortcutbadger.ShortcutBadger

class BadgePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.qwen_chat_openai/badge")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setBadge" -> {
                val count = call.argument<Int>("count") ?: 0
                val success = ShortcutBadger.applyCount(context, count)
                result.success(success)
            }
            "removeBadge" -> {
                val success = ShortcutBadger.removeCount(context)
                result.success(success)
            }
            "isSupported" -> {
                val supported = ShortcutBadger.isBadgeCounterSupported(context)
                result.success(supported)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}


