package com.articlespost.gemini_nano_bridge.ai

import android.util.Log
import com.google.mlkit.genai.common.DownloadStatus
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.prompt.Generation
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class GeminiNanoBridge(messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    private val modelDelegate = lazy { Generation.getClient() }
    private val model by modelDelegate

    private val methodChannel = MethodChannel(messenger, ChannelContract.METHODS)
    private val downloadChannel = EventChannel(messenger, ChannelContract.DOWNLOAD)
    private val generationChannel = EventChannel(messenger, ChannelContract.GENERATION)

    private var downloadJob: Job? = null
    private var generationJob: Job? = null

    init {
        methodChannel.setMethodCallHandler(this)
        downloadChannel.setStreamHandler(DownloadStreamHandler())
        generationChannel.setStreamHandler(GenerationStreamHandler())
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            ChannelContract.METHOD_CHECK_STATUS -> respond(result) { model.checkStatus().toWireStatus() }
            ChannelContract.METHOD_WARMUP -> respond(result) {
                model.warmup()
                null
            }
            ChannelContract.METHOD_BASE_MODEL_NAME -> respond(result) { model.getBaseModelName() }
            else -> result.notImplemented()
        }
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
        downloadChannel.setStreamHandler(null)
        generationChannel.setStreamHandler(null)
        scope.cancel()
        if (modelDelegate.isInitialized()) model.close()
    }

    private fun respond(result: MethodChannel.Result, block: suspend () -> Any?) {
        scope.launch {
            try {
                result.success(block())
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                val error = e.report()
                result.error(error.code, error.message, error.details)
            }
        }
    }

    private inner class DownloadStreamHandler : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
            downloadJob?.cancel()
            downloadJob = scope.launch {
                try {
                    model.download().collect { status -> events.emit(status) }
                } catch (e: CancellationException) {
                    throw e
                } catch (e: Exception) {
                    val error = e.report()
                    events.error(error.code, error.message, error.details)
                }
            }
        }

        override fun onCancel(arguments: Any?) {
            downloadJob?.cancel()
            downloadJob = null
        }

        private fun EventChannel.EventSink.emit(status: DownloadStatus) {
            when (status) {
                is DownloadStatus.DownloadStarted -> success(
                    downloadEvent(ChannelContract.EVENT_STARTED, status.bytesToDownload),
                )
                is DownloadStatus.DownloadProgress -> success(
                    downloadEvent(ChannelContract.EVENT_PROGRESS, status.totalBytesDownloaded),
                )
                is DownloadStatus.DownloadCompleted -> {
                    success(downloadEvent(ChannelContract.EVENT_COMPLETED, null))
                    endOfStream()
                }
                is DownloadStatus.DownloadFailed -> {
                    Log.w(TAG, "Model download failed", status.e)
                    error(ChannelContract.ERROR_DOWNLOAD_FAILED, status.e.message, null)
                }
                else -> Unit
            }
        }

        private fun downloadEvent(type: String, bytes: Long?): Map<String, Any?> =
            mapOf(ChannelContract.EVENT_TYPE to type, ChannelContract.EVENT_BYTES to bytes)
    }

    private inner class GenerationStreamHandler : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
            generationJob?.cancel()
            generationJob = scope.launch {
                try {
                    val request = GenerationRequestParser.parse(arguments)
                    model.generateContentStream(request).collect { chunk ->
                        val text = chunk.candidates.firstOrNull()?.text
                        if (!text.isNullOrEmpty()) events.success(text)
                    }
                    events.endOfStream()
                } catch (e: CancellationException) {
                    throw e
                } catch (e: Exception) {
                    val error = e.report()
                    events.error(error.code, error.message, error.details)
                }
            }
        }

        override fun onCancel(arguments: Any?) {
            generationJob?.cancel()
            generationJob = null
        }
    }

    private fun Int.toWireStatus(): String = when (this) {
        FeatureStatus.AVAILABLE -> ChannelContract.STATUS_AVAILABLE
        FeatureStatus.DOWNLOADABLE -> ChannelContract.STATUS_DOWNLOADABLE
        FeatureStatus.DOWNLOADING -> ChannelContract.STATUS_DOWNLOADING
        else -> ChannelContract.STATUS_UNAVAILABLE
    }

    private fun Exception.report(): BridgeError {
        val error = toBridgeError()
        Log.w(TAG, "Gemini Nano call failed with ${error.code}", this)
        return error
    }

    private companion object {
        const val TAG = "GeminiNanoBridge"
    }
}
