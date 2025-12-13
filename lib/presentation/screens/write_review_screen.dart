import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/review_model.dart';
import '../widgets/custom_button.dart';

class WriteReviewScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String productImage;

  const WriteReviewScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;
  String _selectedTag = 'Sản phẩm';

  final List<String> _tags = [
    'Sản phẩm',
    'Dịch vụ',
    'Giao hàng',
    'Đóng gói',
    'Chất lượng',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung đánh giá'),
          backgroundColor: kRedColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1));

    final review = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user',
      userName: 'Người dùng',
      avatarUrl: '',
      productId: widget.productId,
      reviewText: _reviewController.text.trim(),
      rating: _rating.toDouble(),
      aiScore: 0.85,
      sentiment: _rating >= 4 ? 'Tích cực' : (_rating >= 3 ? 'Trung tính' : 'Tiêu cực'),
      tag: _selectedTag,
      createdAt: DateTime.now(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi đánh giá thành công!'),
          backgroundColor: kGreenColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, review);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: const Text('Viết đánh giá'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductInfo(),
            const SizedBox(height: 24),
            _buildRatingSection(),
            const SizedBox(height: 24),
            _buildTagSection(),
            const SizedBox(height: 24),
            _buildReviewInput(),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Gửi đánh giá',
              onPressed: _isSubmitting ? null : _submitReview,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.productImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: kBorderColor,
                child: const Icon(Icons.image, color: kSecondaryTextColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Đánh giá sản phẩm này',
                  style: TextStyle(
                    color: kSecondaryTextColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá của bạn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = starIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  starIndex <= _rating ? Icons.star : Icons.star_border,
                  color: kYellowColor,
                  size: 40,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _getRatingText(),
            style: TextStyle(
              color: _getRatingColor(),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Rất tệ';
      case 2:
        return 'Tệ';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Tốt';
      case 5:
        return 'Tuyệt vời';
      default:
        return '';
    }
  }

  Color _getRatingColor() {
    if (_rating <= 2) return kRedColor;
    if (_rating == 3) return kYellowColor;
    return kGreenColor;
  }

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Về khía cạnh nào?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            final isSelected = tag == _selectedTag;
            return GestureDetector(
              onTap: () => setState(() => _selectedTag = tag),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? kAccentColor : kCardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? kAccentColor : kBorderColor,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected ? Colors.white : kPrimaryTextColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nội dung đánh giá',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor),
          ),
          child: TextField(
            controller: _reviewController,
            maxLines: 5,
            maxLength: 500,
            style: const TextStyle(color: kPrimaryTextColor),
            decoration: const InputDecoration(
              hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm này...',
              hintStyle: TextStyle(color: kSecondaryTextColor),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              counterStyle: TextStyle(color: kSecondaryTextColor),
            ),
          ),
        ),
      ],
    );
  }
}
