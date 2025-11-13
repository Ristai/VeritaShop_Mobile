import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../core/constants/app_colors.dart';

/// ViewModel cho Product - kết hợp data model với UI properties
class ProductViewModel {
  final ProductModel product;

  // Constructor với ProductModel
  ProductViewModel({required this.product});

  // Named constructor với tất cả parameters (để tương thích với code hiện tại)
  ProductViewModel.fromParams({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String category,
    required double rating,
    required int reviewCount,
    required int stock,
    bool isFeatured = false,
    required DateTime createdAt,
    List<String> tags = const [],
  }) : product = ProductModel(
          id: id,
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          category: category,
          rating: rating,
          reviewCount: reviewCount,
          stock: stock,
          isFeatured: isFeatured,
          createdAt: createdAt,
          tags: tags,
        );

  // Delegate to product model
  String get id => product.id;
  String get name => product.name;
  String get description => product.description;
  double get price => product.price;
  String get imageUrl => product.imageUrl;
  String get category => product.category;
  double get rating => product.rating;
  int get reviewCount => product.reviewCount;
  int get stock => product.stock;
  bool get isFeatured => product.isFeatured;
  DateTime get createdAt => product.createdAt;
  List<String> get tags => product.tags;
  bool get isInStock => product.isInStock;
  bool get isLowStock => product.isLowStock;
  bool get isOutOfStock => product.isOutOfStock;
  String get formattedPrice => product.formattedPrice;

  /// Màu sắc cho trạng thái kho (UI-specific)
  Color get stockStatusColor {
    if (isOutOfStock) return kRedColor;
    if (isLowStock) return kYellowColor;
    return kGreenColor;
  }

  /// Text hiển thị trạng thái kho (UI-specific)
  String get stockStatusText {
    if (isOutOfStock) return 'Hết hàng';
    if (isLowStock) return 'Sắp hết';
    return 'Còn hàng';
  }

  /// Factory constructor từ ProductModel
  factory ProductViewModel.fromModel(ProductModel model) {
    return ProductViewModel(product: model);
  }

}

