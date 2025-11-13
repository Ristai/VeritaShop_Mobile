import '../models/review_model.dart';
import '../data_sources/local/mock_data_source.dart';

/// Repository xử lý logic nghiệp vụ cho đánh giá
class ReviewRepository {
  final MockDataSource _dataSource;

  ReviewRepository({MockDataSource? dataSource})
      : _dataSource = dataSource ?? MockDataSource();

  /// Lấy tất cả đánh giá
  Future<List<ReviewModel>> getAllReviews() async {
    return await _dataSource.getReviews();
  }

  /// Lấy đánh giá theo sản phẩm
  Future<List<ReviewModel>> getReviewsByProductId(String productId) async {
    final reviews = await getAllReviews();
    return reviews.where((r) => r.productId == productId).toList();
  }

  /// Lọc đánh giá theo sentiment
  Future<List<ReviewModel>> getReviewsBySentiment(String sentiment) async {
    final reviews = await getAllReviews();
    return reviews.where((r) => r.sentiment == sentiment).toList();
  }

  /// Lấy đánh giá tích cực
  Future<List<ReviewModel>> getPositiveReviews() async {
    return await getReviewsBySentiment('Tích cực');
  }

  /// Lấy đánh giá tiêu cực
  Future<List<ReviewModel>> getNegativeReviews() async {
    return await getReviewsBySentiment('Tiêu cực');
  }
}

