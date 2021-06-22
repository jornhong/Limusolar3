package com.limutech.pvl

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.flutter.io/bluetooth"
    private val REQUEST_ENABLE_BT = 1
    private var methodChannel: MethodChannel? = null
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler {
            call, result ->
            // Note: this method is invoked on the main thread.
            if (call.method == "enableBluetooth") {
                result.success(enableBluetooth())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun enableBluetooth(): Boolean {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val bluetoothAdapter = bluetoothManager.adapter
        if (!bluetoothAdapter.isEnabled) {
//            return bluetoothAdapter.enable()
            val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT)
            return false
        }
        return true
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            REQUEST_ENABLE_BT -> if (resultCode == Activity.RESULT_OK) {
                methodChannel?.invokeMethod("enableBtResult", true)
            } else {
                methodChannel?.invokeMethod("enableBtResult", false)
            }
        }
    }
}
