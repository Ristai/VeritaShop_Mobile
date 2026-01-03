import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

/// ViewModel quản lý server-side product search với debounce
class SearchViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  // Search state
  String _searchQuery = '';
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalResults = 0;

  // Debounce timer
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  static const int _minQueryLength = 2;

  SearchViewModel({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepository();

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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
