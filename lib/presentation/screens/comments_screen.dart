import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/review_model.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterSentiment = 'Tất cả';
  bool _isLoading = false;

  final List<ReviewModel> _reviews = [
    ReviewModel(
      id: '1',
      userId: 'u1',
      userName: 'Nguyễn Văn A',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      productId: 'p1',
      reviewText: 'Sản phẩm rất tốt, đóng gói cẩn thận, giao hàng nhanh chóng. Rất hài lòng!',
      rating: 5,
      aiScore: 0.92,
      sentiment: 'Tích cực',
      tag: 'Sản phẩm',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ReviewModel(
      id: '2',
      userId: 'u2',
      userName: 'Trần Thị B',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      productId: 'p2',
      reviewText: 'Chất lượng ổn với giá tiền. Tuy nhiên giao hàng hơi chậm so với dự kiến.',
      rating: 3,
      aiScore: 0.55,
      sentiment: 'Trung tính',
      tag: 'Giao hàng',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ReviewModel(
      id: '3',
      userId: 'u3',
      userName: 'Lê Văn C',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      productId: 'p3',
      reviewText: 'Sản phẩm không giống mô tả. Màu sắc khác hoàn toàn. Rất thất vọng!',
      rating: 1,
      aiScore: 0.15,
      sentiment: 'Tiêu cực',
      tag: 'Sản phẩm',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ReviewModel(
      id: '4',
      userId: 'u4',
      userName: 'Phạm Thị D',
      avatarUrl: 'https://i.pravatar.cc/150?img=8',
      productId: 'p4',
      reviewText: 'Dịch vụ chăm sóc khách hàng rất tốt, phản hồi nhanh và giải quyết vấn đề thỏa đáng.',
      rating: 5,
      aiScore: 0.88,
      sentiment: 'Tích cực',
      tag: 'Dịch vụ',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ReviewModel(
      id: '5',
      userId: 'u5',
      userName: 'Hoàng Văn E',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      productId: 'p5',
      reviewText: 'Đóng gói sơ sài, sản phẩm bị móp một góc. Cần cải thiện khâu vận chuyển.',
      rating: 2,
      aiScore: 0.22,
      sentiment: 'Tiêu cực',
      tag: 'Đóng gói',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ReviewModel> get _filteredReviews {
    if (_filterSentiment == 'Tất cả') return _reviews;
    return _reviews.where((r) => r.sentiment == _filterSentiment).toList();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        _buildFilterChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: kAccentColor,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReviews.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredReviews.length,
                        itemBuilder: (context, index) {
                          return _buildReviewCard(_filteredReviews[index]);
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quản lý bình luận',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${5} bình luận chưa xử lý',
                style: TextStyle(color: colors.secondaryText, fontSize: 13),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: kAccentColor,
        unselectedLabelColor: colors.secondaryText,
        indicatorColor: kAccentColor,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: 'Tất cả'),
          Tab(text: 'Chờ xử lý'),
          Tab(text: 'Đã trả lời'),
          Tab(text: 'Spam'),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final colors = AppColors.of(context);
    final sentiments = ['Tất cả', 'Tích cực', 'Trung tính', 'Tiêu cực'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sentiments.length,
        itemBuilder: (context, index) {
          final sentiment = sentiments[index];
          final isSelected = sentiment == _filterSentiment;
          Color chipColor;
          switch (sentiment) {
            case 'Tích cực':
              chipColor = kGreenColor;
              break;
            case 'Trung tính':
              chipColor = kYellowColor;
              break;
            case 'Tiêu cực':
              chipColor = kRedColor;
              break;
            default:
              chipColor = kAccentColor;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(sentiment),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _filterSentiment = sentiment);
              },
              selectedColor: chipColor.withValues(alpha: 0.2),
              checkmarkColor: chipColor,
              labelStyle: TextStyle(
                color: isSelected ? chipColor : colors.secondaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? chipColor : colors.border,
              ),
              backgroundColor: colors.card,
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final colors = AppColors.of(context);
    Color sentimentColor;
    switch (review.sentiment) {
      case 'Tích cực':
        sentimentColor = kGreenColor;
        break;
      case 'Tiêu cực':
        sentimentColor = kRedColor;
        break;
      default:
        sentimentColor = kYellowColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      review.timeAgo,
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sentimentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      review.sentiment == 'Tích cực'
                          ? Icons.sentiment_satisfied
                          : review.sentiment == 'Tiêu cực'
                              ? Icons.sentiment_dissatisfied
                              : Icons.sentiment_neutral,
                      size: 14,
                      color: sentimentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.sentiment,
                      style: TextStyle(
                        color: sentimentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: kYellowColor,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            review.reviewText,
            style: const TextStyle(height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  review.tag,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kAccentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'AI: ${(review.aiScore * 100).toInt()}%',
                  style: const TextStyle(
                    color: kAccentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showReplyDialog(review),
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Trả lời'),
                style: TextButton.styleFrom(
                  foregroundColor: kAccentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, size: 20),
                color: colors.secondaryText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: colors.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Không có bình luận nào',
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(ReviewModel review) {
    final colors = AppColors.of(context);
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trả lời ${review.userName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${review.reviewText}"',
                style: TextStyle(
                  color: colors.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập phản hồi của bạn...',
                hintStyle: TextStyle(color: colors.secondaryText),
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.secondaryText,
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã gửi phản hồi thành công'),
                          backgroundColor: kGreenColor,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Gửi phản hồi'),
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
