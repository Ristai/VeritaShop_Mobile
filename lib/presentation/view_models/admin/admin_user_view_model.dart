import 'package:flutter/foundation.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminUserViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool _isLoading = false;
  String? _error;
  List<dynamic> _users = [];
  Map<String, dynamic>? _pagination;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get users => _users;
  Map<String, dynamic>? get pagination => _pagination;
  String get searchQuery => _searchQuery;
  int get currentPage => _pagination?['page'] ?? 1;
  int get totalPages => _pagination?['pages'] ?? 1;

  Future<void> loadUsers({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getUsers(
        page: page,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      _users = result['users'];
      _pagination = result['pagination'];
      debugPrint('AdminUsers: Loaded ${_users.length} users');
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminUsers Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadUsers();
  }

  Future<bool> toggleUserStatus(String userId) async {
    try {
      await _repository.toggleUserStatus(userId);
      await loadUsers(page: currentPage);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
