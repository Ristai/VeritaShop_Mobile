import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../view_models/product_view_model.dart';

class ProductRecommendations extends StatelessWidget {
  final String title;
  final List<ProductViewModel> products;
  final void Function(ProductViewModel) onProductTap;
  final void Function(ProductViewModel)? onAddToCart;

  const ProductRecommendations({
    super.key,
    this.title = 'Có thể bạn sẽ thích',
    required this.products,
    required this.onProductTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: kAccentColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(products[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductViewModel product) {
    return GestureDetector(
      onTap: () => onProductTap(product),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: kBorderColor,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: kBorderColor,
                  child: const Icon(Icons.image, color: kSecondaryTextColor),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: kYellowColor, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: kSecondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.formattedPrice,
                            style: const TextStyle(
                              color: kAccentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (onAddToCart != null)
                          GestureDetector(
                            onTap: () => onAddToCart!(product),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: kAccentColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimilarProducts extends StatelessWidget {
  final String currentProductId;
  final String category;
  final List<ProductViewModel> allProducts;
  final void Function(ProductViewModel) onProductTap;

  const SimilarProducts({
    super.key,
    required this.currentProductId,
    required this.category,
    required this.allProducts,
    required this.onProductTap,
  });

  List<ProductViewModel> get _similarProducts {
    return allProducts
        .where((p) => p.id != currentProductId && p.category == category)
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProductRecommendations(
      title: 'Sản phẩm tương tự',
      products: _similarProducts,
      onProductTap: onProductTap,
    );
  }
}

class RecentlyViewedProducts extends StatelessWidget {
  final List<ProductViewModel> products;
  final void Function(ProductViewModel) onProductTap;
  final void Function(ProductViewModel)? onAddToCart;

  const RecentlyViewedProducts({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return ProductRecommendations(
      title: 'Đã xem gần đây',
      products: products,
      onProductTap: onProductTap,
      onAddToCart: onAddToCart,
    );
  }
}
