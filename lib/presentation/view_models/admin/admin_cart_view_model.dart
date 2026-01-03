import 'package:flutter/foundation.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminCartViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool _isLoading = false;
  String? _error;
  List<dynamic> _carts = [];
  Map<String, dynamic>? _pagination;
  String _searchQuery = '';
  Map<String, dynamic>? _selectedCart;
  String? _selectedUserId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get carts => _carts;
  Map<String, dynamic>? get pagination => _pagination;
  String get searchQuery => _searchQuery;
  Map<String, dynamic>? get selectedCart => _selectedCart;
  String? get selectedUserId => _selectedUserId;
  int get currentPage => _pagination?['page'] ?? 1;
  int get totalPages => _pagination?['pages'] ?? 1;

  Future<void> loadCarts({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getCarts(
        page: page,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      _carts = result['carts'];
      _pagination = result['pagination'];
      debugPrint('AdminCarts: Loaded ${_carts.length} carts');
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminCarts Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadCarts();
  }

  Future<void> loadCartByUser(String userId) async {
    _isLoading = true;
    _error = null;
    _selectedUserId = userId;
    notifyListeners();

    try {
      final cart = await _repository.getCartByUser(userId);
      _selectedCart = cart;
      debugPrint('AdminCarts: Loaded cart for user $userId');
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminCarts Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedCart() {
    _selectedCart = null;
    _selectedUserId = null;
    notifyListeners();
  }

  Future<bool> updateCartItem(String userId, String itemId, int quantity) async {
    try {
      await _repository.updateCartItem(userId, itemId, quantity);
      await loadCartByUser(userId);
      await loadCarts(page: currentPage);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCartItem(String userId, String itemId) async {
    try {
      await _repository.deleteCartItem(userId, itemId);
      await loadCartByUser(userId);
      await loadCarts(page: currentPage);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearUserCart(String userId) async {
    try {
      await _repository.clearUserCart(userId);
      _selectedCart = {'items': []};
      await loadCarts(page: currentPage);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
