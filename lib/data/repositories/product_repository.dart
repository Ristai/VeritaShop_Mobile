import '../models/product_model.dart';
import '../data_sources/local/mock_data_source.dart';

/// Repository xử lý logic nghiệp vụ cho sản phẩm
class ProductRepository {
  final MockDataSource _dataSource;

  ProductRepository({MockDataSource? dataSource})
      : _dataSource = dataSource ?? MockDataSource();

  /// Lấy tất cả sản phẩm
  Future<List<ProductModel>> getAllProducts() async {
    return await _dataSource.getProducts();
  }

  /// Lấy sản phẩm theo ID
  Future<ProductModel?> getProductById(String id) async {
    return await _dataSource.getProductById(id);
  }

  /// Tìm kiếm sản phẩm
  Future<List<ProductModel>> searchProducts(String query) async {
    final products = await getAllProducts();
    if (query.isEmpty) return products;

    final lowerQuery = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Lọc sản phẩm theo danh mục
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final products = await getAllProducts();
    if (category == 'Tất cả') return products;
    return products.where((p) => p.category == category).toList();
  }

  /// Lấy sản phẩm nổi bật
  Future<List<ProductModel>> getFeaturedProducts() async {
    final products = await getAllProducts();
    return products.where((p) => p.isFeatured).toList();
  }

  /// Sắp xếp sản phẩm
  List<ProductModel> sortProducts(
    List<ProductModel> products,
    String sortBy,
  ) {
    final sorted = List<ProductModel>.from(products);
    switch (sortBy) {
      case 'Giá: Thấp - Cao':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Giá: Cao - Thấp':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Đánh giá cao':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Mới nhất':
      default:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sorted;
  }
}

