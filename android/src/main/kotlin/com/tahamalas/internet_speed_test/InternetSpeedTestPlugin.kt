package com.tahamalas.internet_speed_test

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import fr.bmartel.speedtest.SpeedTestReport
import fr.bmartel.speedtest.SpeedTestSocket
import fr.bmartel.speedtest.inter.IRepeatListener
import fr.bmartel.speedtest.inter.ISpeedTestListener
import fr.bmartel.speedtest.model.SpeedTestError
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


/** InternetSpeedTestPlugin */
public class InternetSpeedTestPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private var result: Result? = null
    private var speedTestSocket: SpeedTestSocket = SpeedTestSocket()

    private lateinit var methodChannel: MethodChannel
    private var activity: Activity? = null
    private var applicationContext: Context? = null
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "internet_speed_test")
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        this.result = result
        when {
            call.method == "startListening" -> mapToCall(result, call.arguments)
            call.method == "cancelListening" -> cancelListening(call.arguments, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        activity = null
        applicationContext = null
        methodChannel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    private fun mapToCall(result: Result, arguments: Any?) {
        val argsMap = arguments as Map<*, *>

        when (val args = argsMap["id"] as Int) {
            CallbacksEnum.START_DOWNLOAD_TESTING.ordinal -> startListening(args, result, "startDownloadTesting", argsMap["testServer"] as String)
            CallbacksEnum.START_UPLOAD_TESTING.ordinal -> startListening(args, result, "startUploadTesting", argsMap["testServer"] as String)
        }
    }

    private val callbackById: MutableMap<Int, Runnable> = mutableMapOf()

    fun startListening(args: Any, result: Result, methodName: String, testServer: String) {
        // Get callback id
        println("testttt")
        val currentListenerId = args as Int
        println("testttt")
        val runnable = Runnable {
            if (callbackById.containsKey(currentListenerId)) {
                val argsMap: MutableMap<String, Any> = mutableMapOf()
                argsMap["id"] = currentListenerId
                println("testttt $currentListenerId")
                when (methodName) {
                    "startDownloadTesting" -> {
                        testDownloadSpeed(object : TestListener {
                            override fun onComplete(transferRate: Double) {
                                argsMap["transferRate"] = transferRate
                                argsMap["type"] = ListenerEnum.COMPLETE.ordinal
                                activity!!.runOnUiThread {
                                    methodChannel.invokeMethod("callListener", argsMap)
                                }
                            }

                            override fun onError(speedTestError: String, errorMessage: String) {
                                argsMap["speedTestError"] = speedTestError
                                argsMap["errorMessage"] = errorMessage
                                argsMap["type"] = ListenerEnum.ERROR.ordinal
                                activity!!.runOnUiThread {
                                    methodChannel.invokeMethod("callListener", argsMap)
                                }
                            }

                            override fun onProgress(percent: Double, transferRate: Double) {
                                println("onProgress $percent, $transferRate")
                                argsMap["percent"] = percent
                                argsMap["transferRate"] = transferRate
                                argsMap["type"] = ListenerEnum.PROGRESS.ordinal
                                activity!!.runOnUiThread {
                                    methodChannel.invokeMethod("callListener", argsMap)
                                }
                            }
                        }, testServer)
                    }
                    "startUploadTesting" -> {
                        testUploadSpeed(object : TestListener {
                            override fun onComplete(transferRate: Double) {
                                argsMap["transferRate"] = transferRate
                                argsMap["type"] = ListenerEnum.COMPLETE.ordinal
                                activity!!.runOnUiThread {
                                    methodChannel.invokeMethod("callListener", argsMap)
                                }
                            }

                            override fun onError(speedTestError: String, errorMessage: String) {
                                argsMap["speedTestError"] = speedTestError
                                argsMap["errorMessage"] = errorMessage
                                argsMap["type"] = ListenerEnum.ERROR.ordinal
                                activity!!.runOnUiThread {
                                    methodChannel.invokeMethod("callListener", argsMap)
                                }
                            }

                            override fun onProgress(percent: Double, transferRate: Double) {
                                argsMap["percent"] = percent
                                argsMap["transferRate"] = transferRate
                                argsMap["type"] = ListenerEnum.PROGRESS.ordinal
                                activity!!.runOnUiThread {
                                    methodChannel.invokeMethod("callListener", argsMap)
                                }
                            }
                        }, testServer)
                    }

                }
                // Send some value to callback

            }
        }
        val thread = Thread(runnable)
        callbackById[currentListenerId] = runnable
        thread.start()
        // Return immediately
        result.success(null)
    }

    private fun testUploadSpeed(testListener: TestListener, testServer: String) {
        // add a listener to wait for speedtest completion and progress
        println("Testing Testing")
        speedTestSocket.addSpeedTestListener(object : ISpeedTestListener {
            override fun onCompletion(report: SpeedTestReport) {
//                // called when download/upload is complete
//                println("[COMPLETED] rate in octet/s : " + report.transferRateOctet)
//                println("[COMPLETED] rate in bit/s   : " + report.transferRateBit)
//                testListener.onComplete(report.transferRateBit.toDouble())
            }

            override fun onError(speedTestError: SpeedTestError, errorMessage: String) {
                // called when a download/upload error occur
                println("OnError: ${speedTestError.name}, $errorMessage")
                testListener.onError(errorMessage, speedTestError.name)
            }

            override fun onProgress(percent: Float, report: SpeedTestReport) {
//                // called to notify download/upload progress
//                println("[PROGRESS] progress : $percent%")
//                println("[PROGRESS] rate in octet/s : " + report.transferRateOctet)
//                println("[PROGRESS] rate in bit/s   : " + report.transferRateBit)
//                testListener.onProgress(percent.toDouble(), report.transferRateBit.toDouble())
            }
        })
//        speedTestSocket.startFixedUpload("http://ipv4.ikoula.testdebit.info/", 10000000, 10000)
        speedTestSocket.startUploadRepeat(testServer, 20000, 500, 2000, object : IRepeatListener {
            override fun onCompletion(report: SpeedTestReport) {
                // called when download/upload is complete
                println("[COMPLETED] rate in octet/s : " + report.transferRateOctet)
                println("[COMPLETED] rate in bit/s   : " + report.transferRateBit)
                testListener.onComplete(report.transferRateBit.toDouble())
            }

            override fun onReport(report: SpeedTestReport) {
                // called to notify download/upload progress
                println("[PROGRESS] progress : ${report.progressPercent}%")
                println("[PROGRESS] rate in octet/s : " + report.transferRateOctet)
                println("[PROGRESS] rate in bit/s   : " + report.transferRateBit)
                testListener.onProgress(report.progressPercent.toDouble(), report.transferRateBit.toDouble())
            }
        })
        println("After Testing")
    }

    private fun testDownloadSpeed(testListener: TestListener, testServer: String) {
        // add a listener to wait for speedtest completion and progress
        println("Testing Testing")
        speedTestSocket.addSpeedTestListener(object : ISpeedTestListener {
            override fun onCompletion(report: SpeedTestReport) {
//                // called when download/upload is complete
//                println("[COMPLETED] rate in octet/s : " + report.transferRateOctet)
//                println("[COMPLETED] rate in bit/s   : " + report.transferRateBit)
//                testListener.onComplete(report.transferRateBit.toDouble())
            }

            override fun onError(speedTestError: SpeedTestError, errorMessage: String) {
                // called when a download/upload error occur
                println("OnError: ${speedTestError.name}, $errorMessage")
                testListener.onError(errorMessage, speedTestError.name)
            }

            override fun onProgress(percent: Float, report: SpeedTestReport) {
//                // called to notify download/upload progress
//                println("[PROGRESS] progress : $percent%")
//                println("[PROGRESS] rate in octet/s : " + report.transferRateOctet)
//                println("[PROGRESS] rate in bit/s   : " + report.transferRateBit)
//                testListener.onProgress(percent.toDouble(), report.transferRateBit.toDouble())
            }
        })
//        speedTestSocket.startDownloadRepeat("http://ipv4.ikoula.testdebit.info/1M.iso", 10000)


        speedTestSocket.startDownloadRepeat(testServer,
                20000, 500, object : IRepeatListener {
            override fun onCompletion(report: SpeedTestReport) {
                // called when download/upload is complete
                println("[COMPLETED] rate in octet/s : " + report.transferRateOctet)
                println("[COMPLETED] rate in bit/s   : " + report.transferRateBit)
                testListener.onComplete(report.transferRateBit.toDouble())
            }

            override fun onReport(report: SpeedTestReport) {
                // called to notify download/upload progress
                println("[PROGRESS] progress : ${report.progressPercent}%")
                println("[PROGRESS] rate in octet/s : " + report.transferRateOctet)
                println("[PROGRESS] rate in bit/s   : " + report.transferRateBit)
                testListener.onProgress(report.progressPercent.toDouble(), report.transferRateBit.toDouble())
            }
        })

        println("After Testing")
    }

    private fun cancelListening(args: Any, result: Result) {
        // Get callback id
        val currentListenerId = args as Int
        // Remove callback
        callbackById.remove(currentListenerId)
        // Do additional stuff if required to cancel the listener
        result.success(null)
    }
}
