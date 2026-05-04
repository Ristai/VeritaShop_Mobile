import 'package:flutter/foundation.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminReportViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool _isLoading = false;
  String? _error;
  
  List<dynamic> _revenueData = [];
  List<dynamic> _topProducts = [];
  List<dynamic> _lowStockProducts = [];
  List<dynamic> _statusDistribution = [];
  List<dynamic> _paymentMethods = [];

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  String _groupBy = 'day';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get revenueData => _revenueData;
  List<dynamic> get topProducts => _topProducts;
  List<dynamic> get lowStockProducts => _lowStockProducts;
  List<dynamic> get statusDistribution => _statusDistribution;
  List<dynamic> get paymentMethods => _paymentMethods;
  DateTime get fromDate => _fromDate;
  DateTime get toDate => _toDate;
  String get groupBy => _groupBy;

  Future<void> loadRevenueReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getRevenueReport(
        from: _fromDate.toIso8601String().split('T')[0],
        to: _toDate.toIso8601String().split('T')[0],
        groupBy: _groupBy,
      );
      _revenueData = result['data'] ?? [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getProductReport();
      _topProducts = result['topProducts'] ?? [];
      _lowStockProducts = result['lowStock'] ?? [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getOrderReport();
      _statusDistribution = result['statusDistribution'] ?? [];
      _paymentMethods = result['paymentMethods'] ?? [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllReports() async {
    await Future.wait([
      loadRevenueReport(),
      loadProductReport(),
      loadOrderReport(),
    ]);
  }

  void setDateRange(DateTime from, DateTime to) {
    _fromDate = from;
    _toDate = to;
    loadRevenueReport();
  }

  void setGroupBy(String groupBy) {
    _groupBy = groupBy;
    loadRevenueReport();
  }
}
