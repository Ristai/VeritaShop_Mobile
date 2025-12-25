import 'package:flutter/foundation.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminCouponViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _coupons = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get coupons => _coupons;

  Future<void> loadCoupons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coupons = await _repository.getCoupons();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCoupon(Map<String, dynamic> data) async {
    try {
      await _repository.createCoupon(data);
      await loadCoupons();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCoupon(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateCoupon(id, data);
      await loadCoupons();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCoupon(String id) async {
    try {
      await _repository.deleteCoupon(id);
      await loadCoupons();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
