import '../models/product_model.dart';
import '../../core/network/api_service.dart';

/// Repository xử lý logic nghiệp vụ cho sản phẩm (điện thoại)
class ProductRepository {
  final ApiService _apiService;

  ProductRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Lấy tất cả sản phẩm với filters
  Future<ProductListResult> getAllProducts({
    int page = 1,
    int limit = 20,
    String? brand,
    String? sort,
    int? minPrice,
    int? maxPrice,
    String? ram,
    String? rom,
    String? condition,
  }) async {
    final response = await _apiService.getProducts(
      page: page,
      limit: limit,
      brand: brand,
      sort: sort,
      minPrice: minPrice,
      maxPrice: maxPrice,
      ram: ram,
      rom: rom,
      condition: condition,
    );

    final List<dynamic> data = response['data'] ?? [];
    final pagination = response['pagination'] ?? {};

    final products = data.map((json) => ProductModel.fromMap(json)).toList();

    return ProductListResult(
      products: products,
      page: pagination['page'] ?? 1,
      totalPages: pagination['totalPages'] ?? 1,
      total: pagination['total'] ?? products.length,
    );
  }

  /// Lấy sản phẩm theo ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await _apiService.getProductById(id);
      if (response['success'] == true && response['data'] != null) {
        return ProductModel.fromMap(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Tìm kiếm sản phẩm
  Future<ProductListResult> searchProducts(String query, {int page = 1}) async {
    final response = await _apiService.searchProducts(query, page: page);

    final List<dynamic> data = response['data'] ?? [];
    final pagination = response['pagination'] ?? {};

    final products = data.map((json) => ProductModel.fromMap(json)).toList();

    return ProductListResult(
      products: products,
      page: pagination['page'] ?? 1,
      totalPages: pagination['totalPages'] ?? 1,
      total: pagination['total'] ?? products.length,
    );
  }

  /// Lọc sản phẩm theo hãng (brand)
  Future<ProductListResult> getProductsByBrand(String brand, {int page = 1}) async {
    if (brand == 'Tất cả') {
      return getAllProducts(page: page);
    }

    final response = await _apiService.getProductsByBrand(brand, page: page);

    final List<dynamic> data = response['data'] ?? [];
    final pagination = response['pagination'] ?? {};

    final products = data.map((json) => ProductModel.fromMap(json)).toList();

    return ProductListResult(
      products: products,
      page: pagination['page'] ?? 1,
      totalPages: pagination['totalPages'] ?? 1,
      total: pagination['total'] ?? products.length,
    );
  }

  /// Lấy danh sách brands
  Future<List<BrandInfo>> getBrands() async {
    final response = await _apiService.getBrands();
    
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> brands = response['data']['brands'] ?? [];
      return brands.map((b) => BrandInfo(
        name: b['name'] ?? '',
        count: b['count'] ?? 0,
      )).toList();
    }
    return [];
  }

  /// Lấy sản phẩm nổi bật
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    final response = await _apiService.getFeaturedProducts(limit: limit);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => ProductModel.fromMap(json)).toList();
    }
    return [];
  }

  /// Sắp xếp sản phẩm (local sort)
  List<ProductModel> sortProducts(List<ProductModel> products, String sortBy) {
    final sorted = List<ProductModel>.from(products);
    switch (sortBy) {
      case 'Giá: Thấp - Cao':
      case 'price_asc':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Giá: Cao - Thấp':
      case 'price_desc':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Đánh giá cao':
      case 'rating':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Mới nhất':
      case 'newest':
      default:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sorted;
  }
}

/// Result class for paginated product list
class ProductListResult {
  final List<ProductModel> products;
  final int page;
  final int totalPages;
  final int total;

  ProductListResult({
    required this.products,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

/// Brand info class
class BrandInfo {
  final String name;
  final int count;

  BrandInfo({required this.name, required this.count});
}
