package com.pureswift.swiftandroid

import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.Spinner
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.viewinterop.AndroidView
import com.pureswift.swiftandroid.ui.theme.SwiftAndroidTheme

class MainActivity : ComponentActivity() {

    init {
        NativeLibrary.shared()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        onCreateSwift(savedInstanceState)
        enableEdgeToEdge()
    }

    external fun onCreateSwift(savedInstanceState: Bundle?)

    fun setRootView(view: View) {
        Log.v("MainActivity", "AndroidSwiftUI.MainActivity.setRootView(_:)")
        setContentView(view)
    }
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