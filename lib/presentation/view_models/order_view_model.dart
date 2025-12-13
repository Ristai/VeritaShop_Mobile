import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/models/address_model.dart';
import '../../data/models/cart_model.dart';

class OrderViewModel extends ChangeNotifier {
  final List<OrderModel> _orders = [];
  final List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  String _selectedPaymentMethod = 'COD';
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  AddressModel? get selectedAddress => _selectedAddress;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final List<String> paymentMethods = [
    'COD',
    'MoMo',
    'VNPay',
    'ZaloPay',
    'Thẻ tín dụng/ghi nợ',
  ];

  Future<void> loadAddresses() async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (_addresses.isEmpty) {
        _addresses.add(AddressModel(
          id: 'addr_1',
          userId: 'demo_user',
          fullName: 'Nguyễn Văn A',
          phone: '0901234567',
          province: 'TP. Hồ Chí Minh',
          district: 'Quận 1',
          ward: 'Phường Bến Nghé',
          streetAddress: '123 Nguyễn Huệ',
          isDefault: true,
          createdAt: DateTime.now(),
        ));
      }
      
      _selectedAddress = _addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => _addresses.first,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOrders() async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      notifyListeners();
    } catch (e) {
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
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (address.isDefault) {
        for (int i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }
      
      _addresses.add(address);
      
      if (address.isDefault || _selectedAddress == null) {
        _selectedAddress = address;
      }
      
      notifyListeners();
      return true;
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
      await Future.delayed(const Duration(milliseconds: 300));
      
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        if (address.isDefault) {
          for (int i = 0; i < _addresses.length; i++) {
            _addresses[i] = _addresses[i].copyWith(isDefault: false);
          }
        }
        _addresses[index] = address;
        
        if (_selectedAddress?.id == address.id) {
          _selectedAddress = address;
        }
      }
      
      notifyListeners();
      return true;
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
      await Future.delayed(const Duration(milliseconds: 300));
      
      _addresses.removeWhere((a) => a.id == addressId);
      
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }
      
      notifyListeners();
      return true;
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
  }) async {
    if (_selectedAddress == null) {
      _setError('Vui lòng chọn địa chỉ giao hàng');
      return null;
    }

    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final order = OrderModel.fromCartSummary(
        id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo_user',
        cartSummary: cartSummary,
        shippingAddress: _selectedAddress!,
        paymentMethod: _selectedPaymentMethod,
        note: note,
      );
      
      _orders.insert(0, order);
      notifyListeners();
      return order;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: OrderStatus.cancelled,
          updatedAt: DateTime.now(),
        );
      }
      
      notifyListeners();
      return true;
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
