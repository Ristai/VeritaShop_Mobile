import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../view_models/wishlist_view_model.dart';
import '../view_models/cart_view_model.dart';
import 'product_detail_screen.dart';
import '../view_models/product_view_model.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        title: const Text('Yêu thích'),
        elevation: 0,
        actions: [
          Consumer<WishlistViewModel>(
            builder: (context, wishlistViewModel, _) {
              if (wishlistViewModel.wishlistItems.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearDialog(context, wishlistViewModel),
              );
            },
          ),
        ],
      ),
      body: Consumer<WishlistViewModel>(
        builder: (context, wishlistViewModel, _) {
          if (wishlistViewModel.wishlistItems.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: kAccentColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistViewModel.wishlistItems.length,
              itemBuilder: (context, index) {
                final product = wishlistViewModel.wishlistItems[index];
                return _buildWishlistItem(context, product, wishlistViewModel);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: kSecondaryTextColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có sản phẩm yêu thích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: kSecondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thêm sản phẩm yêu thích để xem lại sau',
            style: TextStyle(
              color: kSecondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Khám phá sản phẩm'),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(
    BuildContext context,
    dynamic product,
    WishlistViewModel wishlistViewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                product: ProductViewModel(product: product),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 100,
                    height: 100,
                    color: kBackgroundColor,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
                    color: kBackgroundColor,
                    child: const Icon(Icons.image, color: kSecondaryTextColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: const TextStyle(
                        color: kSecondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: kYellowColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          ' (${product.reviewCount})',
                          style: const TextStyle(
                            color: kSecondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kAccentColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite, color: kRedColor),
                    onPressed: () {
                      wishlistViewModel.removeFromWishlist(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã xóa khỏi danh sách yêu thích'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  if (product.isInStock)
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      color: kAccentColor,
                      onPressed: () async {
                        final cartViewModel = context.read<CartViewModel>();
                        final success = await cartViewModel.addToCart(
                          productId: product.id,
                          quantity: 1,
                        );
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã thêm vào giỏ hàng'),
                              backgroundColor: kGreenColor,
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context, WishlistViewModel wishlistViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text('Xóa tất cả'),
        content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm yêu thích?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              wishlistViewModel.clearWishlist();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa tất cả sản phẩm yêu thích'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: kRedColor)),
          ),
        ],
      ),
    );
  }
}
