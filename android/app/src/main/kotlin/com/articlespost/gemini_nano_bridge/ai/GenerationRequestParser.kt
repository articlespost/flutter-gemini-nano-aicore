package com.articlespost.gemini_nano_bridge.ai

import com.google.mlkit.genai.prompt.TextPart
import com.google.mlkit.genai.prompt.generateContentRequest

internal object GenerationRequestParser {
    private const val MAX_PROMPT_LENGTH = 4_000
    private const val MAX_OUTPUT_TOKENS = 4_096
    private const val MAX_TOP_K = 64
    private const val DEFAULT_TEMPERATURE = 0.3f
    private const val DEFAULT_TOP_K = 16
    private const val DEFAULT_MAX_OUTPUT_TOKENS = 512

    fun parse(arguments: Any?) = run {
        val args = arguments as? Map<*, *>
        val prompt = (args?.get(ChannelContract.ARG_PROMPT) as? String)?.trim()
        require(!prompt.isNullOrEmpty()) { "Prompt is required." }
        require(prompt.length <= MAX_PROMPT_LENGTH) { "Prompt exceeds $MAX_PROMPT_LENGTH characters." }

        val temperatureArg = (args?.get(ChannelContract.ARG_TEMPERATURE) as? Number)
            ?.toFloat()
            ?.coerceIn(0f, 1f)
            ?: DEFAULT_TEMPERATURE
        val topKArg = (args?.get(ChannelContract.ARG_TOP_K) as? Number)
            ?.toInt()
            ?.coerceIn(1, MAX_TOP_K)
            ?: DEFAULT_TOP_K
        val maxOutputTokensArg = (args?.get(ChannelContract.ARG_MAX_OUTPUT_TOKENS) as? Number)
            ?.toInt()
            ?.coerceIn(1, MAX_OUTPUT_TOKENS)
            ?: DEFAULT_MAX_OUTPUT_TOKENS

        generateContentRequest(TextPart(prompt)) {
            temperature = temperatureArg
            topK = topKArg
            maxOutputTokens = maxOutputTokensArg
        }
    }
}
