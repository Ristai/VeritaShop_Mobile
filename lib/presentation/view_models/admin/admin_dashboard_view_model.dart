import 'package:flutter/foundation.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _stats = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;

  // Revenue getters
  int get todayRevenue => _stats['revenue']?['today'] ?? 0;
  int get weekRevenue => _stats['revenue']?['week'] ?? 0;
  int get monthRevenue => _stats['revenue']?['month'] ?? 0;
  int get totalRevenue => _stats['revenue']?['total'] ?? 0;

  // Orders getters
  int get todayOrders => _stats['orders']?['today'] ?? 0;
  int get pendingOrders => _stats['orders']?['pending'] ?? 0;
  int get totalOrders => _stats['orders']?['total'] ?? 0;

  // Products getters
  int get totalProducts => _stats['products']?['total'] ?? 0;
  int get outOfStockProducts => _stats['products']?['outOfStock'] ?? 0;

  // Users getters
  int get totalUsers => _stats['users']?['total'] ?? 0;
  int get newUsersThisMonth => _stats['users']?['newThisMonth'] ?? 0;

  // Recent orders & top products
  List<dynamic> get recentOrders => _stats['recentOrders'] ?? [];
  List<dynamic> get topProducts => _stats['topProducts'] ?? [];

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _repository.getDashboardStats();
      debugPrint('AdminDashboard: Loaded stats - Products: $totalProducts, Users: $totalUsers, Orders: $totalOrders');
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminDashboard Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
