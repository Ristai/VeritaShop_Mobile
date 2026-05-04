import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Service xử lý voice search: ghi âm và gọi API transcribe
/// - Singleton pattern
/// - Sử dụng record package cho audio recording
/// - Gọi API transcribe tại honeysocial.click
class VoiceSearchService {
  static final VoiceSearchService _instance = VoiceSearchService._internal();
  factory VoiceSearchService() => _instance;
  VoiceSearchService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));

  // API Configuration
  static const String _transcribeEndpoint =
      'https://api3.honeysocial.click/api/transcribe';
  static const String _model = 'gpt-4o-mini-transcribe';

  // Prompt hints for better accuracy with Vietnamese product names
  static const String _promptHint =
      'iPhone, Samsung, Xiaomi, OPPO, Vivo, Realme, MacBook, iPad, AirPods, Galaxy, Redmi, tai nghe, điện thoại, máy tính';

  // Recording state
  bool _isRecording = false;
  String? _currentRecordingPath;

  // Getters
  bool get isRecording => _isRecording;

  /// Kiểm tra và request microphone permission
  /// Returns true nếu đã được cấp quyền
  Future<PermissionStatus> requestPermission() async {
    final status = await Permission.microphone.request();
    debugPrint('VoiceSearchService: Permission status: $status');
    return status;
  }

  /// Kiểm tra permission hiện tại
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Bắt đầu ghi âm
  /// Throws exception nếu không có permission hoặc đang ghi âm
  Future<void> startRecording() async {
    if (_isRecording) {
      throw VoiceSearchException('Đang ghi âm, vui lòng đợi');
    }

    // Check permission
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw VoiceSearchException(
        'Chưa được cấp quyền microphone',
        code: VoiceSearchErrorCode.permissionDenied,
      );
    }

    try {
      // Start recording with WAV format
      // Use dart:io Directory.systemTemp which doesn't require path_provider plugin
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${Directory.systemTemp.path}/voice_search_$timestamp.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000, // 16kHz - đủ cho speech recognition
          numChannels: 1, // Mono
        ),
        path: _currentRecordingPath!,
      );
      _isRecording = true;
      debugPrint('VoiceSearchService: Started recording to $_currentRecordingPath');
    } catch (e) {
      debugPrint('VoiceSearchService: Failed to start recording: $e');
      _currentRecordingPath = null;
      throw VoiceSearchException(
        'Không thể bắt đầu ghi âm',
        code: VoiceSearchErrorCode.recordingFailed,
      );
    }
  }

  /// Dừng ghi âm và trả về file path
  /// Returns null nếu không đang ghi âm
  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }

    try {
      final path = await _recorder.stop();
      _isRecording = false;
      debugPrint('VoiceSearchService: Stopped recording, file: $path');
      return path;
    } catch (e) {
      debugPrint('VoiceSearchService: Failed to stop recording: $e');
      _isRecording = false;
      _currentRecordingPath = null;
      throw VoiceSearchException(
        'Không thể dừng ghi âm',
        code: VoiceSearchErrorCode.recordingFailed,
      );
    }
  }

  /// Hủy ghi âm và cleanup
  Future<void> cancelRecording() async {
    if (_isRecording) {
      try {
        await _recorder.stop();
      } catch (e) {
        debugPrint('VoiceSearchService: Error stopping recording: $e');
      }
      _isRecording = false;
    }

    // Cleanup temp file
    if (_currentRecordingPath != null) {
      await _cleanupFile(_currentRecordingPath!);
      _currentRecordingPath = null;
    }
  }

  /// Gọi API transcribe và trả về text
  /// Throws VoiceSearchException nếu có lỗi
  Future<String> transcribeAudio(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw VoiceSearchException(
        'File ghi âm không tồn tại',
        code: VoiceSearchErrorCode.fileNotFound,
      );
    }

    try {
      debugPrint('VoiceSearchService: Transcribing file: $filePath');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: 'audio.wav',
        ),
        'model': _model,
        'prompt': _promptHint,
      });

      final response = await _dio.post(
        _transcribeEndpoint,
        data: formData,
      );

      debugPrint('VoiceSearchService: API response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['text'] != null) {
          final text = data['text'] as String;
          debugPrint('VoiceSearchService: Transcribed text: $text');
          return text.trim();
        } else {
          throw VoiceSearchException(
            'Không thể nhận dạng giọng nói',
            code: VoiceSearchErrorCode.transcriptionFailed,
          );
        }
      } else {
        throw VoiceSearchException(
          'Lỗi từ server',
          code: VoiceSearchErrorCode.apiError,
        );
      }
    } on DioException catch (e) {
      debugPrint('VoiceSearchService: DioException: ${e.type} - ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw VoiceSearchException(
          'Hết thời gian chờ, vui lòng thử lại',
          code: VoiceSearchErrorCode.timeout,
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw VoiceSearchException(
          'Không có kết nối mạng',
          code: VoiceSearchErrorCode.networkError,
        );
      } else {
        throw VoiceSearchException(
          'Lỗi kết nối đến server',
          code: VoiceSearchErrorCode.apiError,
        );
      }
    } catch (e) {
      if (e is VoiceSearchException) rethrow;
      debugPrint('VoiceSearchService: Unexpected error: $e');
      throw VoiceSearchException(
        'Đã xảy ra lỗi, vui lòng thử lại',
        code: VoiceSearchErrorCode.unknown,
      );
    } finally {
      // Cleanup audio file after transcription
      await _cleanupFile(filePath);
    }
  }

  /// Cleanup temp audio file
  Future<void> _cleanupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('VoiceSearchService: Cleaned up file: $filePath');
      }
    } catch (e) {
      debugPrint('VoiceSearchService: Failed to cleanup file: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await cancelRecording();
    _recorder.dispose();
  }
}

/// Error codes cho voice search
enum VoiceSearchErrorCode {
  permissionDenied,
  recordingFailed,
  fileNotFound,
  transcriptionFailed,
  networkError,
  timeout,
  apiError,
  unknown,
}

/// Custom exception cho voice search
class VoiceSearchException implements Exception {
  final String message;
  final VoiceSearchErrorCode code;

  VoiceSearchException(
    this.message, {
    this.code = VoiceSearchErrorCode.unknown,
  });

  @override
  String toString() => 'VoiceSearchException: $message (code: $code)';
}
