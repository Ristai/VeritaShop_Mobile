import 'package:flutter/foundation.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/models/review_model.dart';

class AdminReviewViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  bool _isLoading = false;
  String? _error;
  List<ReviewModel> _reviews = [];
  Map<String, dynamic>? _pagination;
  String? _selectedStatus;
  bool? _showFlagged;
  int _flaggedCount = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ReviewModel> get reviews => _reviews;
  Map<String, dynamic>? get pagination => _pagination;
  String? get selectedStatus => _selectedStatus;
  bool? get showFlagged => _showFlagged;
  int get flaggedCount => _flaggedCount;
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
        flagged: _showFlagged,
      );

      // Parse reviews into ReviewModel
      final reviewsData = result['reviews'] as List;
      _reviews = reviewsData
          .map((r) => ReviewModel.fromApiMap(r as Map<String, dynamic>))
          .toList();
      _pagination = result['pagination'];
      _flaggedCount = result['flaggedCount'] ?? 0;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFlaggedReviews({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getFlaggedReviews(page: page);

      // Parse reviews into ReviewModel
      final reviewsData = result['reviews'] as List;
      _reviews = reviewsData
          .map((r) => ReviewModel.fromApiMap(r as Map<String, dynamic>))
          .toList();
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
    _showFlagged = null;
    loadReviews();
  }

  void setFlaggedFilter(bool? flagged) {
    _showFlagged = flagged;
    _selectedStatus = null;
    if (flagged == true) {
      loadFlaggedReviews();
    } else {
      loadReviews();
    }
  }

  void clearFilters() {
    _selectedStatus = null;
    _showFlagged = null;
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

  Future<bool> approveReviewModeration(String reviewId, {String? note}) async {
    try {
      await _repository.approveReviewModeration(reviewId, note: note);
      // Reload based on current filter
      if (_showFlagged == true) {
        await loadFlaggedReviews(page: currentPage);
      } else {
        await loadReviews(page: currentPage);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectReviewModeration(String reviewId, {String? note}) async {
    try {
      await _repository.rejectReviewModeration(reviewId, note: note);
      // Reload based on current filter
      if (_showFlagged == true) {
        await loadFlaggedReviews(page: currentPage);
      } else {
        await loadReviews(page: currentPage);
      }
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
      // Reload based on current filter
      if (_showFlagged == true) {
        await loadFlaggedReviews(page: currentPage);
      } else {
        await loadReviews(page: currentPage);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
