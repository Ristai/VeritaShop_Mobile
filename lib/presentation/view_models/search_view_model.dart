import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../core/services/voice_search_service.dart';

/// ViewModel quản lý server-side product search với debounce
/// Bao gồm cả voice search functionality
class SearchViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;
  final VoiceSearchService _voiceSearchService;

  // Search state
  String _searchQuery = '';
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalResults = 0;

  // Voice search state
  bool _isRecording = false;
  bool _isTranscribing = false;
  Duration _recordingDuration = Duration.zero;
  String? _voiceError;
  Timer? _recordingTimer;
  static const Duration _maxRecordingDuration = Duration(seconds: 30);

  // Debounce timer
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  static const int _minQueryLength = 2;

  SearchViewModel({
    ProductRepository? productRepository,
    VoiceSearchService? voiceSearchService,
  })  : _productRepository = productRepository ?? ProductRepository(),
        _voiceSearchService = voiceSearchService ?? VoiceSearchService();

  // Getters
  String get searchQuery => _searchQuery;
  List<ProductModel> get searchResults => List.unmodifiable(_searchResults);
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalResults => _totalResults;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasError => _errorMessage != null;
  bool get isQueryValid => _searchQuery.length >= _minQueryLength;

  // Voice search getters
  bool get isRecording => _isRecording;
  bool get isTranscribing => _isTranscribing;
  Duration get recordingDuration => _recordingDuration;
  String? get voiceError => _voiceError;
  bool get isVoiceSearchActive => _isRecording || _isTranscribing;

  /// Tìm kiếm với debounce - gọi khi user đang gõ
  void search(String query) {
    _searchQuery = query;
    _errorMessage = null;

    // Cancel timer cũ
    _debounceTimer?.cancel();

    // Nếu query quá ngắn, clear results
    if (query.length < _minQueryLength) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    // Set loading state ngay để UI responsive
    _isSearching = true;
    notifyListeners();

    // Debounce: đợi user ngừng gõ 300ms
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(query);
    });
  }

  /// Tìm kiếm ngay lập tức - gọi khi user submit (Enter/tap suggestion)
  Future<void> searchImmediate(String query) async {
    _debounceTimer?.cancel();
    _searchQuery = query;

    if (query.length < _minQueryLength) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    await _performSearch(query);
  }

  /// Thực hiện search API call
  Future<void> _performSearch(String query) async {
    if (query != _searchQuery) {
      // Query đã thay đổi trong lúc đợi, skip
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();

    try {
      debugPrint('SearchViewModel: Searching for "$query"');
      final result = await _productRepository.searchProducts(query, page: 1);

      // Check lại query có còn match không
      if (query == _searchQuery) {
        _searchResults = result.products;
        _totalPages = result.totalPages;
        _totalResults = result.total;
        _currentPage = result.page;
        debugPrint('SearchViewModel: Found ${result.total} results');
      }
    } catch (e) {
      debugPrint('SearchViewModel: Search error: $e');
      if (query == _searchQuery) {
        _errorMessage = 'Không thể tìm kiếm. Vui lòng kiểm tra kết nối mạng.';
        // Không clear results để user vẫn thấy data cũ (graceful degradation)
      }
    } finally {
      if (query == _searchQuery) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  /// Load thêm kết quả (pagination)
  Future<void> loadMore() async {
    if (_isSearching || _currentPage >= _totalPages) return;

    _isSearching = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _productRepository.searchProducts(
        _searchQuery,
        page: nextPage,
      );

      _searchResults = [..._searchResults, ...result.products];
      _currentPage = result.page;
      _totalPages = result.totalPages;
    } catch (e) {
      debugPrint('SearchViewModel: Load more error: $e');
      _errorMessage = 'Không thể tải thêm kết quả.';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Clear search và reset state
  void clearSearch() {
    _debounceTimer?.cancel();
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    _errorMessage = null;
    _currentPage = 1;
    _totalPages = 1;
    _totalResults = 0;
    notifyListeners();
  }

  /// Clear chỉ error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================================
  // Voice Search Methods
  // =========================================

  /// Bắt đầu voice search
  /// Returns: PermissionStatus để UI xử lý nếu cần
  Future<PermissionStatus?> startVoiceSearch() async {
    if (_isRecording || _isTranscribing) {
      return null;
    }

    _voiceError = null;
    notifyListeners();

    // Request permission
    final status = await _voiceSearchService.requestPermission();

    if (status.isDenied) {
      _voiceError = 'Vui lòng cấp quyền microphone để sử dụng tìm kiếm giọng nói';
      notifyListeners();
      return status;
    }

    if (status.isPermanentlyDenied) {
      _voiceError = 'Quyền microphone bị từ chối. Vui lòng vào Cài đặt để bật.';
      notifyListeners();
      return status;
    }

    try {
      await _voiceSearchService.startRecording();
      _isRecording = true;
      _recordingDuration = Duration.zero;
      notifyListeners();

      // Start recording duration timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
        notifyListeners();

        // Auto-stop at max duration
        if (_recordingDuration >= _maxRecordingDuration) {
          stopVoiceSearch();
        }
      });
    } on VoiceSearchException catch (e) {
      _voiceError = e.message;
      notifyListeners();
    } catch (e) {
      debugPrint('SearchViewModel: Voice search start error: $e');
      _voiceError = 'Không thể bắt đầu ghi âm';
      notifyListeners();
    }

    return status;
  }

  /// Dừng voice search và transcribe
  /// Returns: Transcribed text hoặc null nếu có lỗi
  Future<String?> stopVoiceSearch() async {
    if (!_isRecording) {
      return null;
    }

    // Stop recording timer
    _recordingTimer?.cancel();
    _recordingTimer = null;

    _isRecording = false;
    _isTranscribing = true;
    _voiceError = null;
    notifyListeners();

    try {
      // Stop recording và lấy file path
      final filePath = await _voiceSearchService.stopRecording();
      if (filePath == null) {
        _isTranscribing = false;
        _voiceError = 'Không có file ghi âm';
        notifyListeners();
        return null;
      }

      // Transcribe audio
      final transcribedText = await _voiceSearchService.transcribeAudio(filePath);

      _isTranscribing = false;
      _recordingDuration = Duration.zero;
      notifyListeners();

      if (transcribedText.isNotEmpty) {
        // Không auto-search, trả về text để UI xử lý
        return transcribedText;
      } else {
        _voiceError = 'Không nhận dạng được giọng nói, vui lòng thử lại';
        notifyListeners();
        return null;
      }
    } on VoiceSearchException catch (e) {
      _isTranscribing = false;
      _recordingDuration = Duration.zero;
      _voiceError = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('SearchViewModel: Voice search stop error: $e');
      _isTranscribing = false;
      _recordingDuration = Duration.zero;
      _voiceError = 'Đã xảy ra lỗi, vui lòng thử lại';
      notifyListeners();
      return null;
    }
  }

  /// Hủy voice search đang thực hiện
  Future<void> cancelVoiceSearch() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    if (_isRecording) {
      await _voiceSearchService.cancelRecording();
    }

    _isRecording = false;
    _isTranscribing = false;
    _recordingDuration = Duration.zero;
    _voiceError = null;
    notifyListeners();
  }

  /// Clear voice error
  void clearVoiceError() {
    _voiceError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _recordingTimer?.cancel();
    super.dispose();
  }
}
