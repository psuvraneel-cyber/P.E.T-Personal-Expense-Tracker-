package com.pet.tracker.pet

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register native SMS reader plugin that reads directly from
        // the system content provider — works regardless of default SMS app.
        flutterEngine.plugins.add(SmsReaderPlugin())
    }
}
