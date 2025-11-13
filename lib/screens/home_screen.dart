import 'package:flutter/material.dart';
import 'package:veritashop/view_models/color_view_model.dart';
import 'package:veritashop/view_models/action_card_view_model.dart';
import 'package:veritashop/view_models/review_view_model.dart';
import 'package:veritashop/view_models/trending_topic_view_model.dart';
import 'package:veritashop/view_models/insight_card_view_model.dart';
import 'package:veritashop/screens/product_list_screen.dart';

//==============================================================================
// LỚP CHÍNH CỦA MÀN HÌNH HOME
//==============================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //----------------------------------------------------------------------------
  // MARK: - State Variables (Các biến trạng thái của màn hình)
  //----------------------------------------------------------------------------

  /// Index của tab đang được chọn trong BottomNavigationBar
  int _selectedIndex = 0;

  /// Trạng thái của các nút gạt trong phần Cài đặt nhanh
  bool _realtimeNotify = true;
  bool _autoAnalysis = true;
  bool _filterSensitive = false;

  /// Giá trị đang được chọn của Dropdown
  String _selectedRange = '7 ngày qua';

  /// Dữ liệu (sử dụng các lớp ViewModel đã định nghĩa)
  late final List<ActionCardViewModel> _actionItems;
  late final List<ReviewViewModel> _reviews;
  late final List<TrendingTopicViewModel> _trendingTopics;
  late final List<InsightCardViewModel> _insights;

  //----------------------------------------------------------------------------
  // MARK: - Init & Data Initialization (Khởi tạo dữ liệu)
  //----------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu giả lập khi widget được tạo lần đầu
    _initializeData();
  }

  /// Hàm khởi tạo dữ liệu giả lập cho giao diện
  void _initializeData() {
    _actionItems = [
      ActionCardViewModel(
        icon: Icons.error_outline,
        iconColor: kRedColor,
        title: 'Bình luận tiêu cực cần xử lý',
        status: 'Khẩn cấp',
        statusColor: kRedColor,
        description:
            'Khách hàng phàn nàn về sản phẩm bị lỗi. Cần phản hồi trong 2 giờ.',
      ),
      ActionCardViewModel(
        icon: Icons.update,
        iconColor: kYellowColor,
        title: 'Cập nhật model AI',
        status: 'Lên lịch',
        statusColor: kYellowColor,
        description:
            'Phiên bản mới của model sentiment analysis sẵn sàng triển khai.',
      ),
      ActionCardViewModel(
        icon: Icons.description_outlined,
        iconColor: kAccentColor,
        title: 'Báo cáo tuần hoàn tất',
        status: 'Sẵn sàng',
        statusColor: kGreenColor,
        description:
            'Báo cáo phân tích sentiment tuần này đã được tạo và sẵn sàng gửi.',
      ),
    ];

    _reviews = [
      ReviewViewModel(
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        name: 'Nguyễn Văn A',
        time: '2 phút trước',
        sentiment: 'Tích cực',
        sentimentColor: kGreenColor,
        reviewText:
            'Sản phẩm rất tốt, giao hàng nhanh. Tôi rất hài lòng với chất lượng dịch vụ.',
        aiScore: 0.89,
        rating: 5.0,
        tag: 'Dịch vụ',
      ),
      ReviewViewModel(
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        name: 'Trần Thị B',
        time: '5 phút trước',
        sentiment: 'Trung tính',
        sentimentColor: kYellowColor,
        reviewText: 'Sản phẩm ổn, không có gì đặc biệt. Giá cả hợp lý.',
        aiScore: 0.52,
        rating: 3.0,
        tag: 'Sản phẩm',
      ),
      ReviewViewModel(
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        name: 'Lê Văn C',
        time: '8 phút trước',
        sentiment: 'Tích cực',
        sentimentColor: kGreenColor,
        reviewText:
            'Tuyệt vời! Đội ngũ hỗ trợ rất nhiệt tình. Sẽ quay lại mua thêm.',
        aiScore: 0.94,
        rating: 5.0,
        tag: 'Hỗ trợ',
      ),
    ];

    _trendingTopics = [
      TrendingTopicViewModel(
        topic: '#ChấtLượngSảnPhẩm',
        mentions: '1,245 mentions',
        sentiment: 'Tích cực 89%',
        sentimentColor: kGreenColor,
        statusIcon: Icons.arrow_upward,
        statusText: 'Hot',
        statusColor: kRedColor,
      ),
      TrendingTopicViewModel(
        topic: '#GiaoHàngNhanh',
        mentions: '987 mentions',
        sentiment: 'Tích cực 92%',
        sentimentColor: kGreenColor,
        statusIcon: Icons.trending_up,
        statusText: 'Trending',
        statusColor: kAccentColor,
      ),
      TrendingTopicViewModel(
        topic: '#HỗTrợKháchhàng',
        mentions: '654 mentions',
        sentiment: 'Trung tính 67%',
        sentimentColor: kYellowColor,
        statusIcon: Icons.arrow_downward,
        statusText: 'Cần chú ý',
        statusColor: kYellowColor,
      ),
      TrendingTopicViewModel(
        topic: '#GiáCả',
        mentions: '432 mentions',
        sentiment: 'Tích cực 78%',
        sentimentColor: kGreenColor,
        statusIcon: Icons.horizontal_rule,
        statusText: 'Ổn định',
        statusColor: kSecondaryTextColor,
      ),
    ];

    _insights = [
      InsightCardViewModel(
        icon: Icons.show_chart,
        iconColor: kAccentColor,
        title: 'Tăng trưởng tích cực',
        description:
            'Mức độ hài lòng khách hàng tăng 12% trong tuần qua, chủ yếu từ cải thiện chất lượng sản phẩm.',
        tag: 'Insight',
        tagColor: kAccentColor,
        info: 'Độ tin cậy: 94%',
      ),
      InsightCardViewModel(
        icon: Icons.thumb_up_alt,
        iconColor: kGreenColor,
        title: 'Điểm mạnh nổi bật',
        description:
            'Khách hàng đánh giá cao tốc độ giao hàng và chất lượng dịch vụ hỗ trợ. Nên duy trì và phát triển thêm.',
        tag: 'Recommendation',
        tagColor: kGreenColor,
        info: 'Ưu tiên: Cao',
      ),
      InsightCardViewModel(
        icon: Icons.warning_amber_rounded,
        iconColor: kYellowColor,
        title: 'Cần cải thiện',
        description:
            'Một số khách hàng phàn nàn về thời gian phản hồi hỗ trợ. Đề xuất tăng cường đội ngũ hỗ trợ.',
        tag: 'Action Required',
        tagColor: kYellowColor,
        info: 'Ưu tiên: Trung bình',
      ),
      InsightCardViewModel(
        icon: Icons.online_prediction,
        iconColor: kPurpleColor,
        title: 'Dự đoán xu hướng',
        description:
            'AI dự đoán sẽ có sự gia tăng quan tâm về tính năng bảo hành trong 2 tuần tới.',
        tag: 'Prediction',
        tagColor: kPurpleColor,
        info: 'Độ chính xác: 87%',
      ),
    ];
  }

  //----------------------------------------------------------------------------
  // MARK: - Logic & Event Handlers (Các hàm xử lý logic và sự kiện)
  //----------------------------------------------------------------------------

  /// Xử lý khi một mục trên BottomNavigationBar được nhấn
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _showSnackBar(
      'Chuyển tab sang ${['Trang chủ', 'Phân tích', 'Bình luận', 'Cài đặt'][index]}',
    );
  }

  /// Hàm tiện ích để hiển thị một SnackBar (thanh thông báo ngắn)
  void _showSnackBar(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

  /// Mở một Bottom Sheet (bảng tùy chọn từ dưới lên)
  void _openDetailsSheet(String title, String body) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(body, style: const TextStyle(color: kSecondaryTextColor)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Giả lập việc tải thêm bình luận
  void _loadMoreComments() {
    setState(() {
      _reviews.add(
        ReviewViewModel(
          avatarUrl: 'https://i.pravatar.cc/150?img=7',
          name: 'Phạm Văn D',
          time: '12 phút trước',
          sentiment: 'Tiêu cực',
          sentimentColor: kRedColor,
          reviewText: 'Gói hàng bị trễ 3 ngày, chưa được phản hồi.',
          aiScore: 0.21,
          rating: 2.0,
          tag: 'Giao hàng',
        ),
      );
    });
    _showSnackBar('Đã tải thêm 1 bình luận mới');
  }

  /// Xử lý khi một khoảng thời gian được chọn từ Dropdown
  void _onSelectRange(String? range) {
    if (range == null) return;
    setState(() => _selectedRange = range);
    _showSnackBar('Đã lọc theo: $range');
  }

  /// Mở một trang chi tiết giả lập
  void _openDetailPage(String title) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => _DetailPage(title: title)));
  }

  //----------------------------------------------------------------------------
  // MARK: - Main Build Method (Hàm build giao diện chính)
  //----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MARK: - Trung tâm hành động (từ anh6.png)
              _SectionHeader(
                title: 'Trung tâm hành động',
                actionText: '${_actionItems.length} cần xử lý',
              ),
              const SizedBox(height: 8),
              _ActionCard(
                data: _actionItems[0],
                buttons: [
                  _ActionButton(
                    text: 'Xử lý ngay',
                    isPrimary: true,
                    onPressed: () => _openDetailsSheet(
                      'Xử lý bình luận',
                      _actionItems[0].description,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    text: 'Xem chi tiết',
                    onPressed: () => _openDetailPage(_actionItems[0].title),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ActionCard(
                data: _actionItems[1],
                buttons: [
                  _ActionButton(
                    text: 'Triển khai',
                    onPressed: () => _showSnackBar('Bắt đầu triển khai...'),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    text: 'Xem lịch',
                    onPressed: () => _openDetailPage(_actionItems[1].title),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ActionCard(
                data: _actionItems[2],
                buttons: [
                  _ActionButton(
                    text: 'Gửi báo cáo',
                    onPressed: () => _showSnackBar('Đã gửi báo cáo.'),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    text: 'Xem trước',
                    onPressed: () => _openDetailPage(_actionItems[2].title),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // MARK: - Hệ thống đánh giá AI (từ anh1.png)
              _SectionHeader(title: 'Hệ thống đánh giá AI'),
              Text(
                'Phân tích mức độ hài lòng của khách hàng tự động',
                style: TextStyle(color: kSecondaryTextColor),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '2,847',
                      label: 'Tổng bình luận',
                      change: '+12%',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      value: '87.3%',
                      label: 'Độ chính xác AI',
                      change: '+8%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _RealtimeAnalysisCard(),
              const SizedBox(height: 24),

              // MARK: - Công cụ phân tích AI
              _SectionHeader(
                title: 'Công cụ phân tích AI',
                actionText: 'Xem tất cả',
              ),
              _AiToolCard(
                onActionPressed: () => _openDetailPage('Phân tích cảm xúc'),
                icon: Icons.sentiment_satisfied_alt,
                title: 'Phân tích cảm xúc',
                subtitle: 'Nhận diện điện tử động cảm xúc',
                statusText: 'Đang xử lý:',
                statusValue: '156 bình luận',
                showProgress: true,
              ),
              const SizedBox(height: 12),
              _AiToolCard(
                onActionPressed: () => _openDetailPage('Xử lý ngôn ngữ'),
                icon: Icons.translate,
                title: 'Xử lý ngôn ngữ',
                subtitle: 'Phân tích từ ngữ nghĩa sâu',
                statusText: 'Hoạt động',
                statusColor: kGreenColor,
                stats: const {
                  'Độ chính xác': '94.2%',
                  'Thời gian': '1.2s',
                  'Ngôn ngữ': '15',
                },
              ),
              const SizedBox(height: 24),

              // MARK: - Phân tích thời gian thực (từ anh2.png)
              const _AutoScoringCard(),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Phân tích thời gian thực', isLive: true),
              const SizedBox(height: 6),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final reviewData = _reviews[index];
                  return _ReviewFeedCard(
                    review: reviewData,
                    onPressReply: () => _openDetailsSheet(
                      'Trả lời ${reviewData.name}',
                      reviewData.reviewText,
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _loadMoreComments,
                  style: ElevatedButton.styleFrom(backgroundColor: kCardColor),
                  child: const Text('Xem thêm bình luận'),
                ),
              ),
              const SizedBox(height: 24),

              // MARK: - Phân bổ cảm xúc (từ anh2.png & anh3.png)
              _SectionHeader(
                title: 'Phân bổ cảm xúc',
                actionWidget: _buildDropdownButton(),
              ),
              const SizedBox(height: 12),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorderColor),
                ),
                child: Center(
                  child: Text(
                    'Biểu đồ phân bổ cảm xúc • $_selectedRange',
                    style: const TextStyle(color: kSecondaryTextColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  _SentimentBreakdownCard(
                    icon: '🙂',
                    percentage: '75%',
                    label: 'Tích cực',
                    count: '2,135',
                    color: kGreenColor,
                  ),
                  _SentimentBreakdownCard(
                    icon: '😐',
                    percentage: '20%',
                    label: 'Trung tính',
                    count: '569',
                    color: kYellowColor,
                  ),
                  _SentimentBreakdownCard(
                    icon: '😞',
                    percentage: '5%',
                    label: 'Tiêu cực',
                    count: '143',
                    color: kRedColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // MARK: - Hiệu suất AI Model (từ anh3.png)
              _SectionHeader(
                title: 'Hiệu suất AI Model',
                actionWidget: const Icon(
                  Icons.settings,
                  color: kSecondaryTextColor,
                ),
              ),
              const _AiModelPerformanceCard(
                title: 'Sentiment Analysis v2.1',
                status: 'Đang hoạt động',
                statusColor: kGreenColor,
                metrics: {
                  'Độ chính xác': 94.2,
                  'Tốc độ xử lý': 1.2,
                  'Độ tin cậy': 92.1,
                },
              ),
              const SizedBox(height: 12),
              const _AiModelPerformanceCard(
                title: 'Language Processing v1.8',
                status: 'Đang cập nhật',
                statusColor: kYellowColor,
                metrics: {
                  'Nhận diện ngôn ngữ': 96.8,
                  'Phân tích ngữ pháp': 91.3,
                  'Xử lý ngữ nghĩa': 89.7,
                },
              ),
              const SizedBox(height: 24),

              // MARK: - Chủ đề thịnh hành (từ anh4.png)
              _SectionHeader(
                title: 'Chủ đề thịnh hành',
                actionWidget: _buildUpdateButton(),
              ),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _trendingTopics.length,
                itemBuilder: (context, index) {
                  final topicData = _trendingTopics[index];
                  return _TrendingTopicCard(
                    topic: topicData,
                    onTap: () => _openDetailPage(topicData.topic),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
              ),
              const SizedBox(height: 24),

              // MARK: - AI Insights & Đề xuất (từ anh4.png & anh5.png)
              _SectionHeader(title: 'AI Insights & Đề xuất', isSmart: true),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _insights.length,
                itemBuilder: (context, index) {
                  final insightData = _insights[index];
                  return _InsightCard(
                    insight: insightData,
                    onTap: () => _openDetailPage(insightData.title),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
              ),
              const SizedBox(height: 24),

              // MARK: - Tóm tắt & Cài đặt (từ anh5, anh6, anh7.png)
              _SectionHeader(
                title: 'Tóm tắt phân tích',
                actionWidget: const Row(
                  children: [
                    Icon(Icons.download, size: 16),
                    SizedBox(width: 4),
                    Text('Xuất báo cáo'),
                  ],
                ),
              ),
              const _SummaryGrid(),
              const SizedBox(height: 24),

              _SectionHeader(
                title: 'Cài đặt nhanh',
                actionWidget: const Icon(
                  Icons.settings,
                  color: kSecondaryTextColor,
                ),
              ),
              _SettingToggleCard(
                icon: Icons.notifications_outlined,
                title: 'Thông báo thời gian thực',
                subtitle: 'Nhận thông báo khi có bình luận mới',
                value: _realtimeNotify,
                onChanged: (v) => setState(() => _realtimeNotify = v),
              ),
              const SizedBox(height: 12),
              _SettingToggleCard(
                icon: Icons.smart_toy_outlined,
                title: 'Phân tích tự động',
                subtitle: 'Tự động phân tích sentiment cho bình luận mới',
                value: _autoAnalysis,
                onChanged: (v) => setState(() => _autoAnalysis = v),
              ),
              const SizedBox(height: 12),
              _SettingToggleCard(
                icon: Icons.shield_outlined,
                title: 'Lọc nội dung nhạy cảm',
                subtitle: 'Tự động ẩn bình luận có nội dung không phù hợp',
                value: _filterSensitive,
                onChanged: (v) => setState(() => _filterSensitive = v),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Phân tích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment_outlined),
            label: 'Bình luận',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: kCardColor,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kAccentColor,
        unselectedItemColor: kSecondaryTextColor,
        showUnselectedLabels: true,
      ),
    );
  }

  //----------------------------------------------------------------------------
  // MARK: - UI Helper Methods (Các hàm xây dựng widget phụ trợ)
  //----------------------------------------------------------------------------

  /// Xây dựng AppBar của màn hình
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kBackgroundColor,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: kCardColor,
          child: Icon(Icons.android),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'AI Review',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'Sentiment Analysis',
            style: TextStyle(fontSize: 12, color: kSecondaryTextColor),
          ),
        ],
      ),
      actions: [
        // Nút chuyển đến Products
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProductListScreen(),
                ),
              );
            },
            icon: const Icon(Icons.shopping_bag, color: kAccentColor, size: 18),
            label: const Text(
              'Sản phẩm',
              style: TextStyle(
                color: kAccentColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: kAccentColor.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: kAccentColor),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _showSnackBar('Mở thông báo'),
          icon: const Icon(Icons.notifications_outlined),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () => _openDetailPage('Profile'),
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
            ),
          ),
        ),
      ],
    );
  }

  /// Xây dựng nút Dropdown để chọn khoảng thời gian
  Widget _buildDropdownButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorderColor),
      ),
      child: DropdownButton<String>(
        value: _selectedRange,
        onChanged: _onSelectRange,
        underline: const SizedBox.shrink(),
        isDense: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: kSecondaryTextColor),
        dropdownColor: kCardColor,
        style: const TextStyle(color: kPrimaryTextColor),
        items: ['7 ngày qua', '30 ngày qua', '90 ngày qua']
            .map((range) => DropdownMenuItem(value: range, child: Text(range)))
            .toList(),
      ),
    );
  }

  /// Xây dựng nút Cập nhật
  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: () => _showSnackBar('Đang cập nhật...'),
      style: ElevatedButton.styleFrom(
        backgroundColor: kBorderColor,
        foregroundColor: kPrimaryTextColor,
      ),
      child: const Text('Cập nhật'),
    );
  }
}

//==============================================================================
//|                                                                            |
//|    TẤT CẢ CÁC WIDGET CON (UI COMPONENTS) ĐƯỢC ĐỊNH NGHĨA Ở PHÍA DƯỚI       |
//|                                                                            |
//==============================================================================

// MARK: - _DetailPage (Trang chi tiết giả lập)
class _DetailPage extends StatelessWidget {
  final String title;
  const _DetailPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Nội dung chi tiết cho "$title"')),
    );
  }
}

// MARK: - _InfoCard (Widget nền chung cho các thẻ)
class _InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _InfoCard({
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: child,
    );
  }
}

// MARK: - _ActionButton (Widget nút bấm chung)
class _ActionButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.text,
    this.isPrimary = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? kRedColor.withOpacity(0.9) : kBorderColor,
        foregroundColor: kPrimaryTextColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text),
    );
  }
}

// MARK: - _SectionHeader (Widget cho tiêu đề mỗi mục)
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final Widget? actionWidget;
  final bool isLive;
  final bool isSmart;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.actionWidget,
    this.isLive = false,
    this.isSmart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isLive)
                const Text(
                  ' • Live',
                  style: TextStyle(
                    color: kGreenColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (isSmart)
                const Text(
                  ' • Smart',
                  style: TextStyle(
                    color: kYellowColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (actionWidget != null) actionWidget!,
          if (actionText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorderColor),
              ),
              child: Text(
                actionText!,
                style: const TextStyle(
                  color: kSecondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// MARK: - _ActionCard (Widget cho thẻ trong "Trung tâm hành động")
class _ActionCard extends StatelessWidget {
  final ActionCardViewModel data;
  final List<Widget> buttons;

  const _ActionCard({required this.data, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, color: data.iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                data.status,
                style: TextStyle(
                  color: data.statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: const TextStyle(color: kSecondaryTextColor, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(children: buttons),
        ],
      ),
    );
  }
}

// MARK: - _StatCard (Widget cho thẻ thống kê)
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String change;
  const _StatCard({
    required this.value,
    required this.label,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                label.contains('bình luận')
                    ? Icons.chat_bubble_outline
                    : Icons.show_chart,
                color: kSecondaryTextColor,
                size: 24,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kGreenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: kGreenColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: kSecondaryTextColor)),
        ],
      ),
    );
  }
}

// MARK: - _RealtimeAnalysisCard (Widget cho thẻ Phân tích thời gian thực)
class _RealtimeAnalysisCard extends StatelessWidget {
  const _RealtimeAnalysisCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Phân tích thời gian thực',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.refresh,
                  color: kSecondaryTextColor,
                  size: 20,
                ),
              ),
            ],
          ),
          _buildSentimentBar('Tích cực', 75, kGreenColor),
          _buildSentimentBar('Trung tính', 20, kYellowColor),
          _buildSentimentBar('Tiêu cực', 5, kRedColor),
        ],
      ),
    );
  }

  Widget _buildSentimentBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: kSecondaryTextColor),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: kBorderColor,
                color: color,
                minHeight: 8,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text('$value%', textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

// MARK: - _AiToolCard (Widget cho thẻ Công cụ AI)
class _AiToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String statusText;
  final String? statusValue;
  final Color? statusColor;
  final bool showProgress;
  final Map<String, String>? stats;
  final VoidCallback? onActionPressed;

  const _AiToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusText,
    this.statusValue,
    this.statusColor,
    this.showProgress = false,
    this.stats,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPurpleColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: kPurpleColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: kSecondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor ?? kSecondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (showProgress)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.7,
                        minHeight: 6,
                        color: kAccentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusValue ?? '',
                    style: const TextStyle(
                      color: kSecondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          if (stats != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: stats!.entries
                    .map(
                      (entry) => Column(
                        children: [
                          Text(
                            entry.value,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            entry.key,
                            style: const TextStyle(
                              color: kSecondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          if (onActionPressed != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onActionPressed,
                    child: const Text('Mở công cụ'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// MARK: - _AutoScoringCard (Widget thẻ chấm điểm tự động)
class _AutoScoringCard extends StatelessWidget {
  const _AutoScoringCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: kYellowColor,
            foregroundColor: Colors.black,
            child: Icon(Icons.star, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chấm điểm tự động',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Đánh giá mức độ hài lòng',
                  style: TextStyle(fontSize: 12, color: kSecondaryTextColor),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < 4 ? Icons.star : Icons.star_half,
                        color: kYellowColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('4.3/5.0', style: TextStyle(fontSize: 12)),
                    const Text(
                      ' (2,847 đánh giá)',
                      style: TextStyle(
                        fontSize: 12,
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: kSecondaryTextColor,
          ),
        ],
      ),
    );
  }
}

// MARK: - _ReviewFeedCard (Widget cho mỗi bình luận trong danh sách)
class _ReviewFeedCard extends StatelessWidget {
  final ReviewViewModel review;
  final VoidCallback? onPressReply;

  const _ReviewFeedCard({required this.review, this.onPressReply});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(review.avatarUrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      review.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: review.sentimentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                review.sentiment,
                style: TextStyle(
                  color: review.sentimentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${review.reviewText}"',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: kPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: onPressReply,
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Trả lời'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border, size: 16),
                label: const Text('Lưu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// MARK: - _SentimentBreakdownCard (Widget cho thẻ phân loại cảm xúc)
class _SentimentBreakdownCard extends StatelessWidget {
  final String icon;
  final String percentage;
  final String label;
  final String count;
  final Color color;

  const _SentimentBreakdownCard({
    required this.icon,
    required this.percentage,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _InfoCard(
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label),
            Text(
              '$count bình luận',
              style: const TextStyle(fontSize: 12, color: kSecondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - _AiModelPerformanceCard (Widget cho thẻ hiệu suất AI)
class _AiModelPerformanceCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final Map<String, double> metrics;

  const _AiModelPerformanceCard({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...metrics.entries.map((e) => _buildMetricBar(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, double value) {
    final bool isTime = label.contains('Tốc độ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: kSecondaryTextColor),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: isTime ? 1 - (value / 2) : value / 100,
                color: isTime ? kPurpleColor : kAccentColor,
                backgroundColor: kBorderColor,
                minHeight: 8,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              isTime ? '${value}s' : '$value%',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - _TrendingTopicCard (Widget cho thẻ chủ đề thịnh hành)
class _TrendingTopicCard extends StatelessWidget {
  final TrendingTopicViewModel topic;
  final VoidCallback? onTap;

  const _TrendingTopicCard({required this.topic, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: _InfoCard(
        child: Column(
          children: [
            Row(
              children: [
                Icon(topic.statusIcon, color: topic.sentimentColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    topic.topic,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  topic.mentions,
                  style: const TextStyle(color: kSecondaryTextColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: topic.sentimentColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  topic.sentiment,
                  style: const TextStyle(color: kSecondaryTextColor),
                ),
                const Spacer(),
                Icon(topic.statusIcon, color: topic.statusColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  topic.statusText,
                  style: TextStyle(color: topic.statusColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - _InsightCard (Widget cho thẻ đề xuất của AI)
class _InsightCard extends StatelessWidget {
  final InsightCardViewModel insight;
  final VoidCallback? onTap;

  const _InsightCard({required this.insight, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: _InfoCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: insight.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(insight.icon, color: insight.iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.description,
                    style: const TextStyle(color: kSecondaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: insight.tagColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          insight.tag,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        insight.info,
                        style: const TextStyle(
                          color: kSecondaryTextColor,
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
      ),
    );
  }
}

// MARK: - _SummaryGrid (Widget cho lưới tóm tắt)
class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.0,
        children: const [
          _SummaryGridItem(
            value: '2,847',
            label: 'Tổng bình luận đã phân tích',
          ),
          _SummaryGridItem(value: '1.2s', label: 'Thời gian xử lý trung bình'),
          _SummaryGridItem(value: '94.2%', label: 'Độ chính xác AI'),
          _SummaryGridItem(value: '4.3/5', label: 'Mức độ hài lòng'),
        ],
      ),
    );
  }
}

class _SummaryGridItem extends StatelessWidget {
  final String value;
  final String label;
  const _SummaryGridItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: kSecondaryTextColor, fontSize: 13),
        ),
      ],
    );
  }
}

// MARK: - _SettingToggleCard (Widget cho cài đặt có nút gạt)
class _SettingToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kSecondaryTextColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: kSecondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: kAccentColor),
        ],
      ),
    );
  }
}
