import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../view_models/product_view_model.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/wishlist_view_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/image_zoom_viewer.dart';
import 'write_review_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductViewModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  bool _isAddingToCart = false;

  List<String> get _productImages => [
        widget.product.imageUrl,
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      ];

  void _incrementQuantity() {
    if (_quantity < widget.product.stock) {
      setState(() => _quantity++);
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _addToCart() async {
    setState(() => _isAddingToCart = true);
    
    try {
      final cartViewModel = context.read<CartViewModel>();
      final success = await cartViewModel.addToCart(
        productId: widget.product.id,
        quantity: _quantity,
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm ${widget.product.name} vào giỏ hàng'),
              backgroundColor: kGreenColor,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Xem giỏ',
                textColor: Colors.white,
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể thêm sản phẩm vào giỏ hàng'),
              backgroundColor: kRedColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  void _toggleWishlist() {
    final wishlistViewModel = context.read<WishlistViewModel>();
    final colors = AppColors.of(context);
    wishlistViewModel.toggleWishlist(widget.product.product);
    
    final isNowInWishlist = wishlistViewModel.isInWishlist(widget.product.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowInWishlist
              ? 'Đã thêm vào danh sách yêu thích'
              : 'Đã xóa khỏi danh sách yêu thích',
        ),
        backgroundColor: isNowInWishlist ? kGreenColor : colors.secondaryText,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(),
                _buildProductInfo(),
                _buildQuantitySelector(),
                _buildDescription(),
                _buildSpecifications(),
                _buildReviewsSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    final colors = AppColors.of(context);
    return SliverAppBar(
      backgroundColor: colors.background,
      elevation: 0,
      floating: true,
      pinned: true,
      expandedHeight: 300,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.card.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<WishlistViewModel>(
          builder: (context, wishlistViewModel, _) {
            final isInWishlist = wishlistViewModel.isInWishlist(widget.product.id);
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.card.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isInWishlist ? kRedColor : colors.primaryText,
                ),
              ),
              onPressed: _toggleWishlist,
            );
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.card.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, size: 20),
          ),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: () => ImageZoomViewer.show(
            context,
            _productImages,
            initialIndex: _selectedImageIndex,
          ),
          child: Hero(
            tag: 'product_${widget.product.id}',
            child: CachedNetworkImage(
              imageUrl: _productImages[_selectedImageIndex],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colors.card,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: colors.card,
                child: const Icon(Icons.image, size: 50),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final colors = AppColors.of(context);
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _productImages.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedImageIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedImageIndex = index),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? kAccentColor : colors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CachedNetworkImage(
                  imageUrl: _productImages[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfo() {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kAccentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.product.category,
                  style: const TextStyle(
                    color: kAccentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.product.stockStatusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.product.stockStatusText,
                  style: TextStyle(
                    color: widget.product.stockStatusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: kYellowColor, size: 20),
              const SizedBox(width: 4),
              Text(
                '${widget.product.rating}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                ' (${widget.product.reviewCount} đánh giá)',
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.product.stock} sản phẩm còn lại',
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.product.formattedPrice,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kAccentColor,
            ),
          ),
          if (widget.product.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.product.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          const Text(
            'Số lượng:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _decrementQuantity,
                  icon: const Icon(Icons.remove, size: 20),
                  color: _quantity > 1 ? colors.primaryText : colors.secondaryText,
                ),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _incrementQuantity,
                  icon: const Icon(Icons.add, size: 20),
                  color: _quantity < widget.product.stock
                      ? colors.primaryText
                      : colors.secondaryText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả sản phẩm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: TextStyle(
              color: colors.secondaryText,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications() {
    final colors = AppColors.of(context);
    final specs = [
      {'label': 'Danh mục', 'value': widget.product.category},
      {'label': 'Thương hiệu', 'value': widget.product.tags.isNotEmpty ? widget.product.tags.first : 'N/A'},
      {'label': 'Tình trạng', 'value': widget.product.stockStatusText},
      {'label': 'Đánh giá', 'value': '${widget.product.rating}/5'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông số',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...specs.map((spec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      spec['label']!,
                      style: TextStyle(color: colors.secondaryText),
                    ),
                    Text(
                      spec['value']!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đánh giá',
                style: TextStyle(
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
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openWriteReview,
            icon: const Icon(Icons.rate_review, size: 18),
            label: const Text('Viết đánh giá'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kAccentColor,
              side: const BorderSide(color: kAccentColor),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            colors: colors,
            name: 'Nguyễn Văn A',
            rating: 5,
            comment: 'Sản phẩm rất tốt, đúng mô tả. Giao hàng nhanh chóng.',
            date: '2 ngày trước',
          ),
          Divider(color: colors.border),
          _buildReviewItem(
            colors: colors,
            name: 'Trần Thị B',
            rating: 4,
            comment: 'Chất lượng ổn, giá cả hợp lý. Sẽ ủng hộ lần sau.',
            date: '5 ngày trước',
          ),
        ],
      ),
    );
  }

  void _openWriteReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteReviewScreen(
          productId: widget.product.id,
          productName: widget.product.name,
          productImage: widget.product.imageUrl,
        ),
      ),
    );
  }

  Widget _buildReviewItem({
    required AppColors colors,
    required String name,
    required int rating,
    required String comment,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kAccentColor,
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: kYellowColor,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(
              color: colors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng cộng',
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(widget.product.price * _quantity / 1000000).toStringAsFixed(1)}M đ',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kAccentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: _isAddingToCart ? 'Đang thêm...' : 'Thêm vào giỏ hàng',
                onPressed: widget.product.isInStock && !_isAddingToCart
                    ? _addToCart
                    : null,
                isLoading: _isAddingToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
