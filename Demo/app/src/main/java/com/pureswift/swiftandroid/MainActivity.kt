package com.pureswift.swiftandroid

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.Spinner
import android.widget.TextView
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.fragment.app.FragmentActivity
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.viewinterop.AndroidView
import com.pureswift.swiftandroid.ui.theme.SwiftAndroidTheme

// Extends `FragmentActivity` so both framework and AndroidX fragments can be hosted.
class MainActivity : FragmentActivity() {

    init {
        NativeLibrary.shared()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        registerDemoComposables()   // custom composables must be registered before the first render
        onCreateSwift(savedInstanceState)
        enableEdgeToEdge()
    }

    external fun onCreateSwift(savedInstanceState: Bundle?)

    fun setRootView(view: View) {
        Log.v("MainActivity", "AndroidSwiftUI.MainActivity.setRootView(_:)")
        setContentView(view)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        onActivityResultSwift(requestCode, resultCode, data)
    }

    external fun onActivityResultSwift(requestCode: Int, resultCode: Int, data: Intent?)
}

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
        text = "Hello $name!",
        modifier = modifier
    )
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    SwiftAndroidTheme {
        Greeting("Android")
    }
}