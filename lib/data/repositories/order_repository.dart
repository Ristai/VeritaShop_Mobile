import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import '../../core/network/api_service.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  Future<OrderListResult> getOrders({int page = 1, String? status}) async {
    try {
      debugPrint('OrderRepository: Fetching orders page=$page status=$status');
      final response = await _apiService.getOrders(page: page, status: status);
      debugPrint('OrderRepository: Response success=${response['success']}');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final pagination = response['pagination'] ?? {};
        
        debugPrint('OrderRepository: Got ${data.length} orders');

        final orders = data.map((json) => OrderModel.fromApiMap(json)).toList();

        return OrderListResult(
          orders: orders,
          page: pagination['page'] ?? 1,
          totalPages: pagination['totalPages'] ?? 1,
          total: pagination['total'] ?? orders.length,
        );
      }
      
      debugPrint('OrderRepository: No data in response');
      return OrderListResult(orders: [], page: 1, totalPages: 1, total: 0);
    } catch (e) {
      debugPrint('OrderRepository: Error fetching orders: $e');
      return OrderListResult(orders: [], page: 1, totalPages: 1, total: 0);
    }
  }

  Future<OrderModel?> getOrderById(String id) async {
    try {
      final response = await _apiService.getOrderById(id);
      if (response['success'] == true && response['data'] != null) {
        return OrderModel.fromApiMap(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<OrderModel?> getOrderByNumber(String orderNumber) async {
    try {
      final response = await _apiService.getOrderByNumber(orderNumber);
      if (response['success'] == true && response['data'] != null) {
        return OrderModel.fromApiMap(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<OrderModel?> createOrder({
    required AddressModel shippingAddress,
    required String paymentMethod,
    String? note,
    String? couponCode,
  }) async {
    try {
      final response = await _apiService.createOrder(
        shippingAddress: {
          'fullName': shippingAddress.fullName,
          'phone': shippingAddress.phone,
          'province': shippingAddress.province,
          'district': shippingAddress.district,
          'ward': shippingAddress.ward,
          'streetAddress': shippingAddress.streetAddress,
        },
        paymentMethod: paymentMethod,
        note: note,
        couponCode: couponCode,
      );

      if (response['success'] == true && response['data'] != null) {
        // API returns data.order for createOrder
        final orderData = response['data']['order'] ?? response['data'];
        return OrderModel.fromApiMap(orderData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      final response = await _apiService.cancelOrder(orderId, reason: reason);
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> reorder(String orderId) async {
    try {
      final response = await _apiService.reorder(orderId);
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
}

class OrderListResult {
  final List<OrderModel> orders;
  final int page;
  final int totalPages;
  final int total;

  OrderListResult({
    required this.orders,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}
