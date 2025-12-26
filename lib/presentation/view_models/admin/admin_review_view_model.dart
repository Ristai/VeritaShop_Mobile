import 'package:flutter/foundation.dart';
import '../../../data/repositories/admin_repository.dart';

class AdminReviewViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool _isLoading = false;
  String? _error;
  List<dynamic> _reviews = [];
  Map<String, dynamic>? _pagination;
  String? _selectedStatus;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get reviews => _reviews;
  Map<String, dynamic>? get pagination => _pagination;
  String? get selectedStatus => _selectedStatus;
  int get currentPage => _pagination?['page'] ?? 1;
  int get totalPages => _pagination?['pages'] ?? 1;

  Future<void> loadReviews({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getReviews(
        page: page,
        status: _selectedStatus,
      );
      _reviews = result['reviews'];
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
    loadReviews();
  }

  Future<bool> approveReview(String reviewId) async {
    try {
      await _repository.approveReview(reviewId);
      await loadReviews(page: currentPage);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _repository.deleteReview(reviewId);
      await loadReviews(page: currentPage);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
