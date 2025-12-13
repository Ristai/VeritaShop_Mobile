import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = '7 ngày qua';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildSentimentChart(),
          const SizedBox(height: 24),
          _buildCategoryAnalysis(),
          const SizedBox(height: 24),
          _buildTrendAnalysis(),
          const SizedBox(height: 24),
          _buildTopKeywords(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân tích AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Thống kê và phân tích sentiment',
              style: TextStyle(color: colors.secondaryText),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButton<String>(
            value: _selectedPeriod,
            onChanged: (value) => setState(() => _selectedPeriod = value!),
            underline: const SizedBox.shrink(),
            isDense: true,
            dropdownColor: colors.card,
            items: ['7 ngày qua', '30 ngày qua', '90 ngày qua']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Tổng đánh giá', '2,847', '+12%', kAccentColor),
        _buildStatCard('Tích cực', '68%', '+5%', kGreenColor),
        _buildStatCard('Tiêu cực', '15%', '-3%', kRedColor),
        _buildStatCard('Trung tính', '17%', '+1%', kYellowColor),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String change, Color color) {
    final colors = AppColors.of(context);
    final isPositive = change.startsWith('+');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? kGreenColor : kRedColor).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? kGreenColor : kRedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentChart() {
    final colors = AppColors.of(context);
    return Container(
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
            'Phân bố Sentiment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(flex: 68, child: _buildBar(kGreenColor)),
              const SizedBox(width: 4),
              Expanded(flex: 17, child: _buildBar(kYellowColor)),
              const SizedBox(width: 4),
              Expanded(flex: 15, child: _buildBar(kRedColor)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Tích cực', '68%', kGreenColor),
              _buildLegendItem('Trung tính', '17%', kYellowColor),
              _buildLegendItem('Tiêu cực', '15%', kRedColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(Color color) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryAnalysis() {
    final colors = AppColors.of(context);
    final categories = [
      {'name': 'Sản phẩm', 'positive': 75, 'neutral': 15, 'negative': 10},
      {'name': 'Dịch vụ', 'positive': 60, 'neutral': 25, 'negative': 15},
      {'name': 'Giao hàng', 'positive': 55, 'neutral': 20, 'negative': 25},
      {'name': 'Đóng gói', 'positive': 80, 'neutral': 12, 'negative': 8},
    ];

    return Container(
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
            'Phân tích theo danh mục',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cat['name'] as String),
                        Text(
                          '${cat['positive']}% tích cực',
                          style: const TextStyle(
                            color: kGreenColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          flex: cat['positive'] as int,
                          child: Container(
                            height: 8,
                            decoration: const BoxDecoration(
                              color: kGreenColor,
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: cat['neutral'] as int,
                          child: Container(height: 8, color: kYellowColor),
                        ),
                        Expanded(
                          flex: cat['negative'] as int,
                          child: Container(
                            height: 8,
                            decoration: const BoxDecoration(
                              color: kRedColor,
                              borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    final colors = AppColors.of(context);
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Xu hướng theo thời gian',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kGreenColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: kGreenColor, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '+5.2%',
                      style: TextStyle(
                        color: kGreenColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('T2', 65),
                _buildChartBar('T3', 72),
                _buildChartBar('T4', 58),
                _buildChartBar('T5', 80),
                _buildChartBar('T6', 75),
                _buildChartBar('T7', 68),
                _buildChartBar('CN', 85),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, int value) {
    final colors = AppColors.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: value.toDouble(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [kAccentColor, kAccentColor.withValues(alpha: 0.5)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: colors.secondaryText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTopKeywords() {
    final colors = AppColors.of(context);
    final keywords = [
      {'word': 'chất lượng tốt', 'count': 234, 'sentiment': 'positive'},
      {'word': 'giao hàng nhanh', 'count': 189, 'sentiment': 'positive'},
      {'word': 'đóng gói cẩn thận', 'count': 156, 'sentiment': 'positive'},
      {'word': 'giá hợp lý', 'count': 142, 'sentiment': 'positive'},
      {'word': 'giao chậm', 'count': 87, 'sentiment': 'negative'},
      {'word': 'sản phẩm lỗi', 'count': 45, 'sentiment': 'negative'},
    ];

    return Container(
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
            'Từ khóa nổi bật',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keywords.map((kw) {
              final isPositive = kw['sentiment'] == 'positive';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (isPositive ? kGreenColor : kRedColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isPositive ? kGreenColor : kRedColor).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.sentiment_satisfied : Icons.sentiment_dissatisfied,
                      size: 14,
                      color: isPositive ? kGreenColor : kRedColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      kw['word'] as String,
                      style: TextStyle(
                        color: isPositive ? kGreenColor : kRedColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${kw['count']})',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
