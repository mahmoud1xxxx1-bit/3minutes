package com.threeminutes.game

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Do not auto-register plugins during engine startup.
        // This isolates the first-frame renderer from native plugin initialization.
    }
}
