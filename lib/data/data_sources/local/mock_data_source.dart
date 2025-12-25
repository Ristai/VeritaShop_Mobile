import '../../models/product_model.dart';
import '../../models/review_model.dart';
import '../../models/trending_topic_model.dart';
import '../../models/action_card_model.dart';
import '../../models/insight_card_model.dart';

/// Mock data source - sử dụng dữ liệu giả lập
/// Thay thế bằng API client thật khi có backend
class MockDataSource {
  /// Lấy danh sách sản phẩm
  Future<List<ProductModel>> getProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      ProductModel(
        id: '1',
        name: 'iPhone 15 Pro Max',
        description: 'Điện thoại cao cấp với chip A17 Pro và camera 48MP',
        price: 29990000,
        imageUrl: 'https://images.unsplash.com/photo-1592286927505-c58ba6c3c10b?w=400',
        category: 'Điện thoại',
        rating: 4.8,
        reviewCount: 234,
        stock: 45,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['Apple', 'Premium', 'Hot'],
      ),
      ProductModel(
        id: '2',
        name: 'Samsung Galaxy S24 Ultra',
        description: 'Flagship Android với S Pen và màn hình Dynamic AMOLED',
        price: 26990000,
        imageUrl: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400',
        category: 'Điện thoại',
        rating: 4.7,
        reviewCount: 189,
        stock: 32,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['Samsung', 'Android'],
      ),
      ProductModel(
        id: '3',
        name: 'MacBook Pro 14" M3',
        description: 'Laptop chuyên nghiệp với chip M3 mạnh mẽ',
        price: 49990000,
        imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
        category: 'Laptop',
        rating: 4.9,
        reviewCount: 156,
        stock: 18,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['Apple', 'Premium', 'Laptop'],
      ),
    ];
  }

  /// Lấy sản phẩm theo ID
  Future<ProductModel?> getProductById(String id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Lấy danh sách đánh giá
  Future<List<ReviewModel>> getReviews() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      ReviewModel(
        id: '1',
        userId: '1',
        userName: 'Nguyễn Văn A',
        avatarUrl: 'https://ui-avatars.com/api/?name=Nguyen+Van+A&background=random&size=150',
        productId: '1',
        reviewText: 'Sản phẩm rất tốt, giao hàng nhanh. Tôi rất hài lòng với chất lượng dịch vụ.',
        rating: 5.0,
        aiScore: 0.89,
        sentiment: 'Tích cực',
        tag: 'Dịch vụ',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      ReviewModel(
        id: '2',
        userId: '2',
        userName: 'Trần Thị B',
        avatarUrl: 'https://ui-avatars.com/api/?name=Tran+Thi+B&background=random&size=150',
        productId: '1',
        reviewText: 'Sản phẩm ổn, không có gì đặc biệt. Giá cả hợp lý.',
        rating: 3.0,
        aiScore: 0.52,
        sentiment: 'Trung tính',
        tag: 'Sản phẩm',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  /// Lấy danh sách chủ đề thịnh hành
  Future<List<TrendingTopicModel>> getTrendingTopics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      TrendingTopicModel(
        id: '1',
        topic: '#ChấtLượngSảnPhẩm',
        mentions: 1245,
        positivePercentage: 89,
        neutralPercentage: 8,
        negativePercentage: 3,
        status: 'Hot',
      ),
      TrendingTopicModel(
        id: '2',
        topic: '#GiaoHàngNhanh',
        mentions: 987,
        positivePercentage: 92,
        neutralPercentage: 6,
        negativePercentage: 2,
        status: 'Trending',
      ),
    ];
  }

  /// Lấy danh sách action cards
  Future<List<ActionCardModel>> getActionCards() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      ActionCardModel(
        id: '1',
        title: 'Bình luận tiêu cực cần xử lý',
        description: 'Khách hàng phàn nàn về sản phẩm bị lỗi. Cần phản hồi trong 2 giờ.',
        status: 'Khẩn cấp',
        priority: 'High',
      ),
      ActionCardModel(
        id: '2',
        title: 'Cập nhật model AI',
        description: 'Phiên bản mới của model sentiment analysis sẵn sàng triển khai.',
        status: 'Lên lịch',
        priority: 'Medium',
      ),
    ];
  }

  /// Lấy danh sách insights
  Future<List<InsightCardModel>> getInsights() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      InsightCardModel(
        id: '1',
        title: 'Tăng trưởng tích cực',
        description: 'Mức độ hài lòng khách hàng tăng 12% trong tuần qua, chủ yếu từ cải thiện chất lượng sản phẩm.',
        tag: 'Insight',
        info: 'Độ tin cậy: 94%',
        confidence: 0.94,
      ),
      InsightCardModel(
        id: '2',
        title: 'Điểm mạnh nổi bật',
        description: 'Khách hàng đánh giá cao tốc độ giao hàng và chất lượng dịch vụ hỗ trợ.',
        tag: 'Recommendation',
        info: 'Ưu tiên: Cao',
        confidence: 0.87,
      ),
    ];
  }
}

