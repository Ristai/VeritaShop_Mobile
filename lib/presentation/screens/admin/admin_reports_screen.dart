import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../view_models/admin/admin_report_view_model.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminReportViewModel>().loadAllReports();
    });
  }

  String _formatCurrency(num amount) {
    return formatVND(amount.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminReportViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.revenueData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => vm.loadAllReports(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Báo cáo & Thống kê',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Date Range Picker
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => _selectDateRange(context, vm),
                          child: Text(
                            '${formatVietnamDate(vm.fromDate)} - ${formatVietnamDate(vm.toDate)}',
                          ),
                        ),
                        const Spacer(),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'day', label: Text('Ngày')),
                            ButtonSegment(value: 'week', label: Text('Tuần')),
                            ButtonSegment(value: 'month', label: Text('Tháng')),
                          ],
                          selected: {vm.groupBy},
                          onSelectionChanged: (values) {
                            vm.setGroupBy(values.first);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Revenue Chart
                _buildRevenueChart(context, vm),
                const SizedBox(height: 24),

                // Two columns for other charts
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildTopProductsChart(context, vm)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildOrderStatusChart(context, vm)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _buildTopProductsChart(context, vm),
                        const SizedBox(height: 16),
                        _buildOrderStatusChart(context, vm),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Low Stock Products
                _buildLowStockProducts(context, vm),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueChart(BuildContext context, AdminReportViewModel vm) {
    final colors = AppColors.of(context);
    final data = vm.revenueData;
    
    // Tính tổng doanh thu và số đơn hàng
    final totalRevenue = data.fold<num>(0, (sum, e) => sum + (e['revenue'] ?? 0));
    final totalOrders = data.fold<int>(0, (sum, e) => sum + ((e['orders'] ?? 0) as int));
    
    if (data.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        color: colors.card,
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 64, color: colors.secondaryText),
              const SizedBox(height: 16),
              Text(
                'Chưa có dữ liệu doanh thu',
                style: TextStyle(color: colors.secondaryText, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Dữ liệu sẽ hiển thị khi có đơn hàng hoàn thành',
                style: TextStyle(color: colors.secondaryText.withValues(alpha: 0.7), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['revenue'] ?? 0).toDouble());
    }).toList();
    
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      color: colors.card,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với icon và title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kAccentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.trending_up, color: kAccentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biểu đồ doanh thu',
                        style: TextStyle(
                          color: colors.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${DateFormat('dd/MM').format(vm.fromDate)} - ${formatVietnamDate(vm.toDate)}',
                        style: TextStyle(color: colors.secondaryText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    colors,
                    'Tổng doanh thu',
                    _formatCurrencyFull(totalRevenue),
                    Icons.account_balance_wallet,
                    kGreenColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    colors,
                    'Tổng đơn hàng',
                    totalOrders.toString(),
                    Icons.shopping_bag,
                    kAccentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    colors,
                    'Trung bình/đơn',
                    totalOrders > 0 ? _formatCurrencyFull(totalRevenue / totalOrders) : '0đ',
                    Icons.analytics,
                    kPurpleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Chart
            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colors.border.withValues(alpha: 0.5),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 65,
                        interval: maxY > 0 ? maxY / 4 : 1,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              _formatCurrency(value),
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: data.length > 10 ? (data.length / 6).ceil().toDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final dateStr = data[index]['_id'] ?? '';
                            String label;
                            if (vm.groupBy == 'month') {
                              label = dateStr.length >= 7 ? dateStr.substring(5) : dateStr;
                            } else if (vm.groupBy == 'week') {
                              label = dateStr;
                            } else {
                              label = dateStr.length > 5 ? dateStr.substring(5) : dateStr;
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colors.secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minY > 0 ? 0 : minY,
                  maxY: maxY * 1.1,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spot) => colors.card,
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          final dateStr = index < data.length ? (data[index]['_id'] ?? '') : '';
                          final orders = index < data.length ? (data[index]['orders'] ?? 0) : 0;
                          return LineTooltipItem(
                            '$dateStr\n',
                            TextStyle(
                              color: colors.secondaryText,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: _formatCurrencyFull(spot.y),
                                style: const TextStyle(
                                  color: kAccentColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '\n$orders đơn hàng',
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: kAccentColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      shadow: Shadow(
                        color: kAccentColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            kAccentColor.withValues(alpha: 0.3),
                            kAccentColor.withValues(alpha: 0.1),
                            kAccentColor.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(
                        show: spots.length <= 15,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: colors.card,
                            strokeWidth: 2,
                            strokeColor: kAccentColor,
                          );
                        },
                      ),
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

  Widget _buildSummaryCard(AppColors colors, String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatCurrencyFull(num amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(2)}B đ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M đ';
    }
    return '${NumberFormat('#,###').format(amount)} đ';
  }

  Widget _buildTopProductsChart(BuildContext context, AdminReportViewModel vm) {
    final data = vm.topProducts;
    if (data.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: const Text('Chưa có dữ liệu sản phẩm'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top sản phẩm bán chạy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (data.map((e) => (e['revenue'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b)) * 1.2,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatCurrency(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            final name = data[index]['name'] ?? '';
                            return SizedBox(
                              width: 50,
                              child: Text(
                                name.length > 8 ? '${name.substring(0, 8)}...' : name,
                                style: const TextStyle(fontSize: 9),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: (e.value['revenue'] ?? 0).toDouble(),
                          color: Colors.primaries[e.key % Colors.primaries.length],
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusChart(BuildContext context, AdminReportViewModel vm) {
    final data = vm.statusDistribution;
    if (data.isEmpty) {
      return Card(
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: const Text('Chưa có dữ liệu đơn hàng'),
        ),
      );
    }

    final total = data.fold<int>(0, (sum, e) => sum + ((e['count'] ?? 0) as int));
    final colors = {
      'pending': Colors.orange,
      'confirmed': Colors.blue,
      'processing': Colors.indigo,
      'shipped': Colors.cyan,
      'delivered': Colors.green,
      'completed': Colors.teal,
      'cancelled': Colors.red,
      'refunded': Colors.grey,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phân bố trạng thái đơn hàng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: data.map((e) {
                          final status = e['_id'] ?? '';
                          final count = (e['count'] ?? 0) as int;
                          final percentage = total > 0 ? (count / total * 100) : 0;
                          return PieChartSectionData(
                            value: count.toDouble(),
                            color: colors[status] ?? Colors.grey,
                            title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            radius: 60,
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.map((e) {
                      final status = e['_id'] ?? '';
                      final count = (e['count'] ?? 0) as int;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[status] ?? Colors.grey,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_getStatusText(status)}: $count',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockProducts(BuildContext context, AdminReportViewModel vm) {
    final data = vm.lowStockProducts;
    if (data.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Sản phẩm sắp hết hàng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.map((product) {
                return Chip(
                  avatar: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _buildProductImage(product['images'], 24),
                  ),
                  label: Text(
                    '${product['name']} (${product['stock']})',
                    style: TextStyle(
                      color: (product['stock'] ?? 0) == 0 ? Colors.red : Colors.orange,
                    ),
                  ),
                  backgroundColor: (product['stock'] ?? 0) == 0
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Chờ xác nhận';
      case 'confirmed': return 'Đã xác nhận';
      case 'processing': return 'Đang xử lý';
      case 'shipped': return 'Đang giao';
      case 'delivered': return 'Đã giao';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      case 'refunded': return 'Hoàn tiền';
      default: return status;
    }
  }

  Future<void> _selectDateRange(BuildContext context, AdminReportViewModel vm) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: vm.fromDate, end: vm.toDate),
    );
    if (picked != null) {
      vm.setDateRange(picked.start, picked.end);
    }
  }

  Widget _buildProductImage(dynamic images, double size) {
    String imageUrl = '';
    if (images is List && images.isNotEmpty) {
      imageUrl = images.first.toString();
    } else if (images is String && images.isNotEmpty) {
      imageUrl = images;
    }
    
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.image, size: size * 0.6),
      );
    }
    return Icon(Icons.image, size: size * 0.6);
  }
}
