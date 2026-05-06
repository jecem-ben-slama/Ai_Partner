package com.example.ai_partner

import android.content.Context
import android.net.*
import android.net.wifi.WifiNetworkSpecifier
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "wifi_connector"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "connectWifi") {
                    val ssid = call.argument<String>("ssid") ?: ""
                    val password = call.argument<String>("password") ?: ""

                    connectToWifi(ssid, password, result)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun connectToWifi(
        ssid: String,
        password: String,
        result: MethodChannel.Result
    ) {

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.success(false)
            return
        }

        val specifierBuilder = WifiNetworkSpecifier.Builder()
            .setSsid(ssid)

        if (password.isNotEmpty()) {
            specifierBuilder.setWpa2Passphrase(password)
        }

        val specifier = specifierBuilder.build()

        val request = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            .setNetworkSpecifier(specifier)
            .build()

        val connectivityManager =
            applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                connectivityManager.bindProcessToNetwork(network)
            }
        }

        connectivityManager.requestNetwork(request, callback)

        result.success(true)
    }
}