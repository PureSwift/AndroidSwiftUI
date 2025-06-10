package com.pureswift.swiftandroid

/// Swift object retained by JVM
class SwiftObject(val swiftObject: Long, val type: String) {

    fun getSwiftObject(): Long {
        return this.swiftObject
    }

    fun getType(): String {
        return this.type
    }

    fun finalize() {
        finalizeSwift()
    }

    external fun finalizeSwift(): String
}