package com.articlespost.gemini_nano_bridge.ai

internal object ChannelContract {
    private const val PREFIX = "com.articlespost.gemini_nano"

    const val METHODS = "$PREFIX/methods"
    const val DOWNLOAD = "$PREFIX/download"
    const val GENERATION = "$PREFIX/generation"

    const val METHOD_CHECK_STATUS = "checkStatus"
    const val METHOD_WARMUP = "warmup"
    const val METHOD_BASE_MODEL_NAME = "baseModelName"

    const val STATUS_AVAILABLE = "available"
    const val STATUS_DOWNLOADABLE = "downloadable"
    const val STATUS_DOWNLOADING = "downloading"
    const val STATUS_UNAVAILABLE = "unavailable"

    const val EVENT_TYPE = "type"
    const val EVENT_BYTES = "bytes"
    const val EVENT_STARTED = "started"
    const val EVENT_PROGRESS = "progress"
    const val EVENT_COMPLETED = "completed"

    const val ARG_PROMPT = "prompt"
    const val ARG_TEMPERATURE = "temperature"
    const val ARG_TOP_K = "topK"
    const val ARG_MAX_OUTPUT_TOKENS = "maxOutputTokens"

    const val ERROR_BUSY = "BUSY"
    const val ERROR_BACKGROUND_USE_BLOCKED = "BACKGROUND_USE_BLOCKED"
    const val ERROR_QUOTA_EXCEEDED = "QUOTA_EXCEEDED"
    const val ERROR_NOT_AVAILABLE = "NOT_AVAILABLE"
    const val ERROR_REQUEST_TOO_LARGE = "REQUEST_TOO_LARGE"
    const val ERROR_NOT_ENOUGH_DISK_SPACE = "NOT_ENOUGH_DISK_SPACE"
    const val ERROR_AICORE_INCOMPATIBLE = "AICORE_INCOMPATIBLE"
    const val ERROR_DOWNLOAD_FAILED = "DOWNLOAD_FAILED"
    const val ERROR_INVALID_ARGUMENT = "INVALID_ARGUMENT"
    const val ERROR_UNKNOWN = "UNKNOWN"

    const val DETAIL_RETRY_DELAY_MS = "retryDelayMs"
}
