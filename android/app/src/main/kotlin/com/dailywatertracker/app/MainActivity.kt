package com.dailywatertracker.app

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Allow Flutter to paint edge-to-edge; insets are handled with SafeArea / MediaQuery.padding.
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }

    /**
     * Fix for go_router cold-start assertion:
     * Some Android launches (notably from notification taps / certain intents) may provide an initial
     * route name that does not start with '/', which trips go_router's matcher.
     *
     * We force a stable initial route for this app.
     */
    override fun getInitialRoute(): String {
        return "/splash"
    }
}
