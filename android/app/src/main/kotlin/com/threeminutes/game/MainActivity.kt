package com.threeminutes.game

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.threeminutes.game/invites"
    private var inviteChannel: MethodChannel? = null
    private var pendingRoomCode: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingRoomCode = roomCodeFromIntent(intent) ?: pendingRoomCode
        inviteChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialRoomCode" -> {
                        val code = pendingRoomCode
                        pendingRoomCode = null
                        result.success(code)
                    }
                    "shareRoomInvite" -> {
                        val text = call.argument<String>("text")?.trim()
                        if (text == null || !Regex("^threeminutes://join/[A-Z0-9]{5}$").matches(text)) {
                            result.error("invalid_invite", "Invalid room invitation link.", null)
                        } else {
                            shareInvite(text)
                            result.success(true)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        inviteChannel = null
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val code = roomCodeFromIntent(intent) ?: return
        val channel = inviteChannel
        if (channel == null) {
            pendingRoomCode = code
        } else {
            channel.invokeMethod("roomInvite", code)
        }
    }

    private fun roomCodeFromIntent(intent: Intent?): String? {
        val uri = intent?.data ?: return null
        if (uri.scheme != "threeminutes" || uri.host != "join") return null
        val code = uri.pathSegments.firstOrNull()?.trim()?.uppercase() ?: return null
        return if (Regex("^[A-Z0-9]{5}$").matches(code)) code else null
    }

    private fun shareInvite(text: String) {
        val sendIntent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
        }
        startActivity(Intent.createChooser(sendIntent, "3 Minutes"))
    }
}
