import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class WishlistViewModel extends ChangeNotifier {
  final List<ProductModel> _wishlistItems = [];
  final bool _isLoading = false;

  List<ProductModel> get wishlistItems => List.unmodifiable(_wishlistItems);
  bool get isLoading => _isLoading;
  int get itemCount => _wishlistItems.length;

  bool isInWishlist(String productId) {
    return _wishlistItems.any((item) => item.id == productId);
  }

  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }

  void addToWishlist(ProductModel product) {
    if (!isInWishlist(product.id)) {
      _wishlistItems.add(product);
      notifyListeners();
    }
  }

  void removeFromWishlist(String productId) {
    _wishlistItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}
