import '../models/coupon_model.dart';
import '../../core/network/api_service.dart';

class CouponRepository {
  final ApiService _apiService;

  CouponRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  Future<List<CouponModel>> getCoupons() async {
    try {
      final response = await _apiService.getCoupons();
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => CouponModel.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<AppliedCoupon?> applyCoupon(String code, double orderAmount) async {
    try {
      final response = await _apiService.applyCoupon(code, orderAmount);
      
      if (response['success'] == true && response['data'] != null) {
        return AppliedCoupon.fromMap(response['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<CouponModel?> getCouponByCode(String code) async {
    try {
      final response = await _apiService.getCouponByCode(code);
      
      if (response['success'] == true && response['data'] != null) {
        return CouponModel.fromMap(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
