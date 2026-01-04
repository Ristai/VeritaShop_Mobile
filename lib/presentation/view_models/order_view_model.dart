import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/models/address_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../core/network/api_service.dart';
import '../../core/services/local_notification_service.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final ApiService _apiService;
  final LocalNotificationService _notificationService = LocalNotificationService();

  List<OrderModel> _orders = [];
  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  String _selectedPaymentMethod = 'COD';
  bool _isLoading = false;
  String? _errorMessage;

  OrderViewModel({
    OrderRepository? orderRepository,
    ApiService? apiService,
  })  : _orderRepository = orderRepository ?? OrderRepository(),
        _apiService = apiService ?? ApiService.instance;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  AddressModel? get selectedAddress => _selectedAddress;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final List<String> paymentMethods = [
    'COD',
    'MoMo',
  ];

  Future<void> loadAddresses() async {
    _setLoading(true);
    try {
      final response = await _apiService.getProfile();
      if (response['success'] == true && response['data'] != null) {
        final userData = response['data'];
        final List<dynamic> addressesData = userData['addresses'] ?? [];
        
        _addresses = addressesData.map((addr) => AddressModel(
          id: addr['_id'] ?? addr['id'] ?? '',
          userId: userData['_id'] ?? '',
          fullName: addr['fullName'] ?? '',
          phone: addr['phone'] ?? '',
          province: addr['province'] ?? '',
          district: addr['district'] ?? '',
          ward: addr['ward'] ?? '',
          streetAddress: addr['streetAddress'] ?? '',
          isDefault: addr['isDefault'] ?? false,
          createdAt: DateTime.now(),
        )).toList();
        
        if (_addresses.isNotEmpty) {
          _selectedAddress = _addresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => _addresses.first,
          );
        }
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOrders() async {
    _setLoading(true);
    try {
      print('OrderViewModel: Loading orders...');
      final result = await _orderRepository.getOrders();
      print('OrderViewModel: Got ${result.orders.length} orders');
      _orders = result.orders;
      notifyListeners();
    } catch (e) {
      print('OrderViewModel: Error loading orders: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void selectPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  Future<bool> addAddress(AddressModel address) async {
    _setLoading(true);
    try {
      final response = await _apiService.addAddress({
        'fullName': address.fullName,
        'phone': address.phone,
        'province': address.province,
        'district': address.district,
        'ward': address.ward,
        'streetAddress': address.streetAddress,
        'isDefault': address.isDefault,
      });
      
      if (response['success'] == true) {
        await loadAddresses();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAddress(AddressModel address) async {
    _setLoading(true);
    try {
      final response = await _apiService.updateAddress(address.id, {
        'fullName': address.fullName,
        'phone': address.phone,
        'province': address.province,
        'district': address.district,
        'ward': address.ward,
        'streetAddress': address.streetAddress,
        'isDefault': address.isDefault,
      });
      
      if (response['success'] == true) {
        await loadAddresses();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    _setLoading(true);
    try {
      final response = await _apiService.deleteAddress(addressId);
      
      if (response['success'] == true) {
        _addresses.removeWhere((a) => a.id == addressId);
        if (_selectedAddress?.id == addressId) {
          _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<OrderModel?> placeOrder({
    required CartSummary cartSummary,
    String? note,
    String? couponCode,
  }) async {
    if (_selectedAddress == null) {
      _setError('Vui lòng chọn địa chỉ giao hàng');
      return null;
    }

    _setLoading(true);
    try {
      final order = await _orderRepository.createOrder(
        shippingAddress: _selectedAddress!,
        paymentMethod: _selectedPaymentMethod,
        note: note,
        couponCode: couponCode,
      );
      
      if (order != null) {
        _orders.insert(0, order);
        notifyListeners();

        // Chỉ gửi notification ngay cho COD
        // MoMo sẽ gửi notification sau khi thanh toán thành công
        if (_selectedPaymentMethod == 'COD') {
          await _notificationService.notifyNewOrder(order.id);

          // Lên lịch nhắc nhở đánh giá sau 3 ngày
          if (order.items.isNotEmpty) {
            await _notificationService.scheduleReviewReminder(
              productName: order.items.first.productName,
              orderId: order.id,
            );
          }
        }

        return order;
      }
      
      _setError('Đặt hàng thất bại');
      return null;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    _setLoading(true);
    try {
      final success = await _orderRepository.cancelOrder(orderId, reason: reason);
      
      if (success) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(
            status: OrderStatus.cancelled,
            updatedAt: DateTime.now(),
          );
        }
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> reorder(String orderId) async {
    _setLoading(true);
    try {
      final success = await _orderRepository.reorder(orderId);
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
