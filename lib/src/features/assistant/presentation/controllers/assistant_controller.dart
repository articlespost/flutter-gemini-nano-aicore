import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gemini_nano_bridge/src/core/errors/errors_exports.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_availability.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/domain/entities/model_download_update.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/models/generation_request_model.dart';
import 'package:gemini_nano_bridge/src/features/assistant/data/services/assistant_service.dart';
import 'package:gemini_nano_bridge/src/features/assistant/presentation/state/assistant_state.dart';

class AssistantController extends ValueNotifier<AssistantState> {
  AssistantController(this._service) : super(const AssistantState());

  final AssistantService _service;
  final StringBuffer _responseBuffer = StringBuffer();

  StreamSubscription<ModelDownloadUpdate>? _downloadSubscription;
  StreamSubscription<String>? _generationSubscription;
  bool _isDisposed = false;

  Future<void> prepare() async {
    _emit(value.copyWith(status: AssistantStatus.checking, clearError: true));
    final result = await _service.checkAvailability();
    if (_isDisposed) return;

    switch (result) {
      case Success(value: ModelAvailability.available):
        await _activateModel();
      case Success(
        value: ModelAvailability.downloadable || ModelAvailability.downloading,
      ):
        await _startDownload();
      case Success(value: ModelAvailability.unavailable):
        _emit(value.copyWith(status: AssistantStatus.unsupported));
      case Failure(:final error):
        _emit(
          value.copyWith(
            status: _isPermanent(error.code)
                ? AssistantStatus.unsupported
                : AssistantStatus.failed,
            errorCode: error.code,
          ),
        );
    }
  }

  void submit(String prompt) {
    if (!value.canSubmit || prompt.trim().isEmpty) return;

    unawaited(_generationSubscription?.cancel());
    _responseBuffer.clear();
    _emit(
      value.copyWith(
        status: AssistantStatus.generating,
        response: '',
        clearError: true,
      ),
    );

    _generationSubscription = _service
        .generate(GenerationRequestModel(prompt: prompt))
        .listen(
          _onChunk,
          onError: _onGenerationError,
          onDone: _onGenerationDone,
          cancelOnError: true,
        );
  }

  Future<void> stop() async {
    final subscription = _generationSubscription;
    if (subscription == null) return;
    _generationSubscription = null;
    await subscription.cancel();
    _emit(value.copyWith(status: AssistantStatus.ready));
  }

  Future<void> _activateModel() async {
    final modelName = await _service.fetchModelName();
    await _service.warmup();
    if (_isDisposed) return;
    _emit(
      value.copyWith(
        status: AssistantStatus.ready,
        modelName: modelName.when(
          success: (name) => name,
          failure: (_) => null,
        ),
      ),
    );
  }

  Future<void> _startDownload() async {
    await _downloadSubscription?.cancel();
    _emit(
      value.copyWith(
        status: AssistantStatus.downloading,
        totalBytes: 0,
        downloadedBytes: 0,
      ),
    );
    _downloadSubscription = _service.downloadModel().listen(
      _onDownloadUpdate,
      onError: _onDownloadError,
      onDone: _onDownloadDone,
      cancelOnError: true,
    );
  }

  void _onDownloadUpdate(ModelDownloadUpdate update) {
    _emit(switch (update) {
      ModelDownloadStarted(:final totalBytes) => value.copyWith(
        totalBytes: totalBytes,
      ),
      ModelDownloadProgress(:final downloadedBytes) => value.copyWith(
        downloadedBytes: downloadedBytes,
      ),
      ModelDownloadCompleted() => value.copyWith(
        downloadedBytes: value.totalBytes,
      ),
    });
  }

  void _onDownloadError(Object error) {
    _downloadSubscription = null;
    _emit(
      value.copyWith(status: AssistantStatus.failed, errorCode: _codeOf(error)),
    );
  }

  void _onDownloadDone() {
    _downloadSubscription = null;
    if (!_isDisposed) unawaited(prepare());
  }

  void _onChunk(String chunk) {
    _responseBuffer.write(chunk);
    _emit(value.copyWith(response: _responseBuffer.toString()));
  }

  void _onGenerationError(Object error) {
    _generationSubscription = null;
    _emit(
      value.copyWith(status: AssistantStatus.ready, errorCode: _codeOf(error)),
    );
  }

  void _onGenerationDone() {
    _generationSubscription = null;
    _emit(value.copyWith(status: AssistantStatus.ready));
  }

  void _emit(AssistantState state) {
    if (!_isDisposed) value = state;
  }

  static AppErrorCode _codeOf(Object error) =>
      error is AppError ? error.code : AppErrorCode.unknown;

  static bool _isPermanent(AppErrorCode code) =>
      code == AppErrorCode.notAvailable;

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_downloadSubscription?.cancel());
    unawaited(_generationSubscription?.cancel());
    super.dispose();
  }
}
