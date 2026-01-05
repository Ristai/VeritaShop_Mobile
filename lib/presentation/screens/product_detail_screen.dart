import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../view_models/product_view_model.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/wishlist_view_model.dart';
import '../widgets/image_zoom_viewer.dart';
import '../widgets/sentiment_badge.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';
import 'write_review_screen.dart';
import 'checkout_screen.dart';

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
  bool _isBuyingNow = false;

  // Review state
  final ReviewRepository _reviewRepository = ReviewRepository();
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = true;
  int _totalReviews = 0;

  // Track unblurred flagged reviews
  final Set<String> _unblurredReviewIds = {};

  List<String> get _productImages => [
        widget.product.imageUrl,
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      ];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    print('Loading reviews for product: ${widget.product.id}');
    try {
      final result = await _reviewRepository.getProductReviews(
        widget.product.id,
        page: 1,
        sort: 'newest',
      );
      print('Loaded ${result.reviews.length} reviews, total: ${result.totalReviews}');
      if (mounted) {
        setState(() {
          _reviews = result.reviews;
          _totalReviews = result.totalReviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      print('Error loading reviews: $e');
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

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
      final defaultColor = widget.product.colors.isNotEmpty 
          ? widget.product.colors.first.toMap() 
          : {'name': 'Mặc định', 'hex': '#000000'};
      final success = await cartViewModel.addToCart(
        productId: widget.product.id,
        quantity: _quantity,
        color: defaultColor,
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

  /// Xử lý mua ngay - chuyển thẳng đến checkout
  Future<void> _buyNow() async {
    setState(() => _isBuyingNow = true);

    try {
      final defaultColor = widget.product.colors.isNotEmpty
          ? widget.product.colors.first.toMap()
          : {'name': 'Mặc định', 'hex': '#000000'};

      final directItem = DirectCheckoutItem(
        productId: widget.product.id,
        productName: widget.product.name,
        productImageUrl: widget.product.imageUrl,
        price: widget.product.price,
        quantity: _quantity,
        color: defaultColor,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutScreen(directCheckoutItem: directItem),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBuyingNow = false);
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
              if (_totalReviews > 2)
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
          if (_isLoadingReviews)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: kAccentColor),
              ),
            )
          else if (_reviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.rate_review_outlined,
                        size: 48, color: colors.secondaryText),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có đánh giá nào',
                      style: TextStyle(color: colors.secondaryText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hãy là người đầu tiên đánh giá sản phẩm này!',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < _reviews.length && i < 3; i++) ...[
                  _buildReviewItemFromModel(_reviews[i], colors),
                  if (i < _reviews.length - 1 && i < 2)
                    Divider(color: colors.border),
                ],
              ],
            ),
        ],
      ),
    );
  }

  void _openWriteReview() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteReviewScreen(
          productId: widget.product.id,
          productName: widget.product.name,
          productImage: widget.product.imageUrl,
        ),
      ),
    );
    // Reload reviews if a new review was submitted
    if (result != null) {
      _loadReviews();
    }
  }

  Widget _buildReviewItemFromModel(ReviewModel review, AppColors colors) {
    final bool isBlurred = review.isFlagged && !_unblurredReviewIds.contains(review.id);
    final categories = review.flaggedCategoriesVietnamese;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flagged content warning banner
          if (review.isFlagged) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_unblurredReviewIds.contains(review.id)) {
                    _unblurredReviewIds.remove(review.id);
                  } else {
                    _unblurredReviewIds.add(review.id);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isBlurred ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nội dung có thể không phù hợp',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isBlurred
                                    ? 'Nhấn để xem nội dung'
                                    : 'Nhấn để ẩn nội dung',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isBlurred ? Icons.expand_more : Icons.expand_less,
                          color: Colors.red.shade700,
                        ),
                      ],
                    ),
                    // Show flagged categories
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: categories.map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ]
          // Pending moderation notice (for non-flagged pending reviews)
          else if (review.isPendingModeration) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Đánh giá đang chờ duyệt',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Review content - with blur effect if flagged
          Stack(
            children: [
              // Actual content
              AnimatedOpacity(
                opacity: isBlurred ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: isBlurred,
                  child: _buildReviewContent(review, colors),
                ),
              ),
              // Blur overlay
              if (isBlurred)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          // Blurred placeholder content
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 60,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Blur filter
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors.card.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.visibility_off,
                                      size: 32,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Nội dung đã được ẩn',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewContent(ReviewModel review, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: kAccentColor,
              backgroundImage: review.avatarUrl.isNotEmpty
                  ? NetworkImage(review.avatarUrl)
                  : null,
              child: review.avatarUrl.isEmpty
                  ? Text(
                      review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      // Overall sentiment badge
                      if (review.sentimentAnalysis.isNotEmpty)
                        OverallSentimentBadge(
                          overallSentiment: review.overallSentiment,
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          color: kYellowColor,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        review.timeAgo,
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
          review.reviewText,
          style: TextStyle(
            color: colors.secondaryText,
            height: 1.4,
          ),
        ),
        // Review images
        if (review.images.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: review.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => ImageZoomViewer.show(
                    context,
                    review.images,
                    initialIndex: index,
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: review.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: colors.card,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: colors.card,
                          child: Icon(Icons.image, color: colors.secondaryText),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        // Sentiment badges for aspects
        if (review.sentimentAnalysis.isNotEmpty) ...[
          const SizedBox(height: 10),
          SentimentBadgeList(
            sentimentAnalysis: review.sentimentAnalysis,
            compact: true,
            maxItems: 4,
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar() {
    final colors = AppColors.of(context);
    final isDisabled = !widget.product.isInStock;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hiển thị tổng cộng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng',
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 14,
                  ),
                ),
                Text(
                  formatVND(widget.product.price * _quantity),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kAccentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Hai nút: Thêm vào giỏ hàng và Mua ngay
            Row(
              children: [
                // Nút Thêm vào giỏ hàng (outlined)
                Expanded(
                  child: OutlinedButton(
                    onPressed: isDisabled || _isAddingToCart ? null : _addToCart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kAccentColor,
                      side: BorderSide(
                        color: isDisabled ? colors.border : kAccentColor,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isAddingToCart
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kAccentColor,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 18,
                                color: isDisabled ? colors.secondaryText : kAccentColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Thêm giỏ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDisabled ? colors.secondaryText : kAccentColor,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nút Mua ngay (filled)
                Expanded(
                  child: ElevatedButton(
                    onPressed: isDisabled || _isBuyingNow ? null : _buyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      disabledBackgroundColor: colors.border,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isBuyingNow
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flash_on, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Mua ngay',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
