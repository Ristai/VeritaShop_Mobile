import '../models/review_model.dart';
import '../../core/network/api_service.dart';

class ReviewRepository {
  final ApiService _apiService;

  ReviewRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  Future<ReviewListResult> getProductReviews(
    String productId, {
    int page = 1,
    String sort = 'newest',
    int? rating,
  }) async {
    final response = await _apiService.getProductReviews(
      productId,
      page: page,
      sort: sort,
      rating: rating,
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      final pagination = response['pagination'] ?? {};
      final summary = response['summary'] ?? {};

      final reviews = data.map((json) => ReviewModel.fromApiMap(json)).toList();

      return ReviewListResult(
        reviews: reviews,
        page: pagination['page'] ?? 1,
        totalPages: pagination['totalPages'] ?? 1,
        total: pagination['total'] ?? reviews.length,
        averageRating: (summary['averageRating'] ?? 0).toDouble(),
        totalReviews: summary['totalReviews'] ?? 0,
      );
    }

    return ReviewListResult(
      reviews: [],
      page: 1,
      totalPages: 1,
      total: 0,
      averageRating: 0,
      totalReviews: 0,
    );
  }

  Future<ReviewListResult> getMyReviews({int page = 1}) async {
    final response = await _apiService.getMyReviews(page: page);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      final pagination = response['pagination'] ?? {};

      final reviews = data.map((json) => ReviewModel.fromApiMap(json)).toList();

      return ReviewListResult(
        reviews: reviews,
        page: pagination['page'] ?? 1,
        totalPages: pagination['totalPages'] ?? 1,
        total: pagination['total'] ?? reviews.length,
        averageRating: 0,
        totalReviews: 0,
      );
    }

    return ReviewListResult(
      reviews: [],
      page: 1,
      totalPages: 1,
      total: 0,
      averageRating: 0,
      totalReviews: 0,
    );
  }

  Future<ReviewModel?> createReview({
    required String productId,
    required int rating,
    required String text,
    String? title,
    List<String>? images,
  }) async {
    try {
      final response = await _apiService.createReview(
        productId: productId,
        rating: rating,
        text: text,
        title: title,
        images: images,
      );

      if (response['success'] == true && response['data'] != null) {
        return ReviewModel.fromApiMap(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<ReviewModel?> updateReview(
    String reviewId, {
    int? rating,
    String? text,
    String? title,
  }) async {
    try {
      final response = await _apiService.updateReview(
        reviewId,
        rating: rating,
        text: text,
        title: title,
      );

      if (response['success'] == true && response['data'] != null) {
        return ReviewModel.fromApiMap(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      final response = await _apiService.deleteReview(reviewId);
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> likeReview(String reviewId) async {
    try {
      final response = await _apiService.likeReview(reviewId);
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
}

class ReviewListResult {
  final List<ReviewModel> reviews;
  final int page;
  final int totalPages;
  final int total;
  final double averageRating;
  final int totalReviews;

  ReviewListResult({
    required this.reviews,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.averageRating,
    required this.totalReviews,
  });
}
