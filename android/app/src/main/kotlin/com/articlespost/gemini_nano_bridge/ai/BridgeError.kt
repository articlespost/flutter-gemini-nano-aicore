package com.articlespost.gemini_nano_bridge.ai

import com.google.mlkit.genai.common.GenAiException

internal data class BridgeError(
    val code: String,
    val message: String?,
    val details: Map<String, Any>?,
)

internal fun Throwable.toBridgeError(): BridgeError = when (this) {
    is GenAiException -> BridgeError(
        code = errorCode.toWireCode(),
        message = message,
        details = mapOf(ChannelContract.DETAIL_RETRY_DELAY_MS to (retryDelay?.toMillis() ?: 0L)),
    )
    is IllegalArgumentException -> BridgeError(ChannelContract.ERROR_INVALID_ARGUMENT, message, null)
    else -> BridgeError(ChannelContract.ERROR_UNKNOWN, null, null)
}

private fun Int.toWireCode(): String = when (this) {
    GenAiException.ErrorCode.BUSY -> ChannelContract.ERROR_BUSY
    GenAiException.ErrorCode.BACKGROUND_USE_BLOCKED -> ChannelContract.ERROR_BACKGROUND_USE_BLOCKED
    GenAiException.ErrorCode.PER_APP_BATTERY_USE_QUOTA_EXCEEDED -> ChannelContract.ERROR_QUOTA_EXCEEDED
    GenAiException.ErrorCode.NOT_AVAILABLE -> ChannelContract.ERROR_NOT_AVAILABLE
    GenAiException.ErrorCode.REQUEST_TOO_LARGE -> ChannelContract.ERROR_REQUEST_TOO_LARGE
    GenAiException.ErrorCode.NOT_ENOUGH_DISK_SPACE -> ChannelContract.ERROR_NOT_ENOUGH_DISK_SPACE
    GenAiException.ErrorCode.AICORE_INCOMPATIBLE -> ChannelContract.ERROR_AICORE_INCOMPATIBLE
    else -> "GENAI_$this"
}
