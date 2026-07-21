package com.pureswift.swiftandroid

// `java.lang.Runnable` backed by a Swift closure.
class Runnable(private val block: SwiftObject?) : java.lang.Runnable {

    fun getBlock(): SwiftObject? = block

    external override fun run()
}
