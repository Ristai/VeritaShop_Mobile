import 'package:flutter/foundation.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/models/product_model.dart';

class AdminProductViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool _isLoading = false;
  String? _error;
  List<ProductModel> _products = [];
  Map<String, dynamic>? _pagination;
  String _searchQuery = '';
  String? _selectedBrand;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProductModel> get products => _products;
  Map<String, dynamic>? get pagination => _pagination;
  String get searchQuery => _searchQuery;
  String? get selectedBrand => _selectedBrand;
  int get currentPage => _pagination?['page'] ?? 1;
  int get totalPages => _pagination?['pages'] ?? 1;

  Future<void> loadProducts({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getProducts(
        page: page,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        brand: _selectedBrand,
      );
      _products = result['products'];
      _pagination = result['pagination'];
      debugPrint('AdminProducts: Loaded ${_products.length} products');
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminProducts Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadProducts();
  }

  void setSelectedBrand(String? brand) {
    _selectedBrand = brand;
    loadProducts();
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    try {
      await _repository.createProduct(data);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateProduct(id, data);
      await loadProducts(page: currentPage);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      await loadProducts(page: currentPage);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
