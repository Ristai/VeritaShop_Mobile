import 'package:flutter/foundation.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminOrderViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool _isLoading = false;
  String? _error;
  List<dynamic> _orders = [];
  Map<String, dynamic>? _pagination;
  String? _selectedStatus;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get orders => _orders;
  Map<String, dynamic>? get pagination => _pagination;
  String? get selectedStatus => _selectedStatus;
  int get currentPage => _pagination?['page'] ?? 1;
  int get totalPages => _pagination?['pages'] ?? 1;

  static const List<String> statuses = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'completed',
    'cancelled',
    'refunded',
  ];

  Future<void> loadOrders({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getOrders(
        page: page,
        status: _selectedStatus,
      );
      _orders = result['orders'];
      _pagination = result['pagination'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    loadOrders();
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    // Optimistic update - cập nhật UI ngay lập tức
    final orderIndex = _orders.indexWhere((o) => o['_id'] == orderId);
    if (orderIndex == -1) return false;
    
    final oldStatus = _orders[orderIndex]['status'];
    _orders[orderIndex] = Map<String, dynamic>.from(_orders[orderIndex])..['status'] = status;
    notifyListeners();
    
    try {
      await _repository.updateOrderStatus(orderId, status);
      // Reload để sync với server (không hiện loading)
      _repository.getOrders(page: currentPage, status: _selectedStatus).then((result) {
        _orders = result['orders'];
        _pagination = result['pagination'];
        notifyListeners();
      });
      return true;
    } catch (e) {
      // Rollback nếu lỗi
      _orders[orderIndex] = Map<String, dynamic>.from(_orders[orderIndex])..['status'] = oldStatus;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> refundOrder(String orderId) async {
    try {
      await _repository.refundOrder(orderId);
      await loadOrders(page: currentPage);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Chờ xác nhận';
      case 'confirmed': return 'Đã xác nhận';
      case 'processing': return 'Đang xử lý';
      case 'shipped': return 'Đang giao';
      case 'delivered': return 'Đã giao';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      case 'refunded': return 'Đã hoàn tiền';
      default: return status;
    }
  }
}
