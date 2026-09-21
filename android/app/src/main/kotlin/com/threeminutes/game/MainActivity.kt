package com.threeminutes.game

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val channelName = "com.threeminutes.game/invites"
    private var inviteChannel: MethodChannel? = null
    private var pendingRoomCode: String? = null
    private var pluginsRegistered = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Keep Flutter's first frame independent from generated native plugins.
        pendingRoomCode = roomCodeFromIntent(intent) ?: pendingRoomCode

        inviteChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPendingRoomCode" -> {
                        result.success(pendingRoomCode)
                        pendingRoomCode = null
                    }
                    else -> result.notImplemented()
                }
            }
        }

        val displayListener = object : FlutterUiDisplayListener {
            override fun onFlutterUiDisplayed() {
                if (pluginsRegistered) return
                pluginsRegistered = true
                flutterEngine.renderer.removeIsDisplayingFlutterUiListener(this)
                try {
                    GeneratedPluginRegistrant.registerWith(flutterEngine)
                } catch (error: Throwable) {
                    android.util.Log.e(
                        "LVL_LOOL",
                        "Deferred plugin registration failed",
                        error,
                    )
                }
            }

            override fun onFlutterUiNoLongerDisplayed() = Unit
        }

        flutterEngine.renderer.addIsDisplayingFlutterUiListener(displayListener)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        roomCodeFromIntent(intent)?.let { code ->
            pendingRoomCode = code
        }
    }

    override fun onDestroy() {
        inviteChannel?.setMethodCallHandler(null)
        inviteChannel = null
        super.onDestroy()
    }

    private fun roomCodeFromIntent(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_VIEW) return null
        val uri = intent.data ?: return null
        if (uri.scheme != "threeminutes" || uri.host != "join") return null
        return uri.getQueryParameter("room")?.trim()?.takeIf { it.isNotEmpty() }
    }
}
