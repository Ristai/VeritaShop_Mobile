import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../view_models/admin/admin_dashboard_view_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminDashboardViewModel>().loadDashboard();
    });
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B đ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M đ';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K đ';
    }
    return '${NumberFormat('#,###').format(amount)} đ';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return Consumer<AdminDashboardViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.stats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: kAccentColor),
                const SizedBox(height: 16),
                Text(
                  'Đang tải dữ liệu...',
                  style: TextStyle(color: colors.secondaryText),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => vm.loadDashboard(),
          color: kAccentColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(colors),
                const SizedBox(height: 24),
                
                // Stats Cards
                _buildStatsGrid(vm, colors),
                const SizedBox(height: 24),

                // Charts Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildRecentOrders(vm, colors)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildTopProducts(vm, colors)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _buildRecentOrders(vm, colors),
                        const SizedBox(height: 24),
                        _buildTopProducts(vm, colors),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Quick Actions
                _buildQuickActions(colors),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(AppColors colors) {
    final now = DateTime.now();
    String greeting;
    if (now.hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (now.hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kAccentColor,
            kPurpleColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chào mừng trở lại với Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildWelcomeStat('Hôm nay', DateFormat('dd/MM/yyyy').format(now)),
                    const SizedBox(width: 24),
                    _buildWelcomeStat('Thời gian', DateFormat('HH:mm').format(now)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AdminDashboardViewModel vm, AppColors colors) {
    final stats = [
      _StatData(
        title: 'Doanh thu tháng',
        value: _formatCurrency(vm.monthRevenue),
        subtitle: 'Hôm nay: ${_formatCurrency(vm.todayRevenue)}',
        icon: Icons.attach_money,
        color: kGreenColor,
        trend: '+12.5%',
        trendUp: true,
      ),
      _StatData(
        title: 'Tổng đơn hàng',
        value: vm.totalOrders.toString(),
        subtitle: 'Chờ xử lý: ${vm.pendingOrders}',
        icon: Icons.shopping_bag,
        color: kAccentColor,
        trend: '+8.2%',
        trendUp: true,
      ),
      _StatData(
        title: 'Sản phẩm',
        value: vm.totalProducts.toString(),
        subtitle: 'Hết hàng: ${vm.outOfStockProducts}',
        icon: Icons.inventory_2,
        color: kYellowColor,
        trend: '+3',
        trendUp: true,
      ),
      _StatData(
        title: 'Khách hàng',
        value: vm.totalUsers.toString(),
        subtitle: 'Mới tháng này: ${vm.newUsersThisMonth}',
        icon: Icons.people,
        color: kPurpleColor,
        trend: '+15.3%',
        trendUp: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 2
                : 1;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.4,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _buildStatCard(stats[index], colors),
        );
      },
    );
  }

  Widget _buildStatCard(_StatData stat, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stat.icon, color: stat.color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stat.trendUp 
                      ? kGreenColor.withValues(alpha: 0.1)
                      : kRedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      stat.trendUp ? Icons.trending_up : Icons.trending_down,
                      color: stat.trendUp ? kGreenColor : kRedColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stat.trend,
                      style: TextStyle(
                        color: stat.trendUp ? kGreenColor : kRedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            stat.value,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.title,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 14,
            ),
          ),
          if (stat.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              stat.subtitle!,
              style: TextStyle(
                color: stat.color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentOrders(AdminDashboardViewModel vm, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kAccentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt_long, color: kAccentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Đơn hàng gần đây',
                    style: TextStyle(
                      color: colors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (vm.recentOrders.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: colors.secondaryText),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có đơn hàng',
                      style: TextStyle(color: colors.secondaryText),
                    ),
                  ],
                ),
              ),
            )
          else
            ...vm.recentOrders.take(5).map((order) => _buildOrderItem(order, colors)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order, AppColors colors) {
    final status = order['status'] as String?;
    final statusColor = _getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.shopping_bag, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['orderNumber'] ?? '',
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order['user']?['name'] ?? 'Khách hàng',
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency((order['total'] ?? order['totalAmount'] ?? 0).toInt()),
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts(AdminDashboardViewModel vm, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kYellowColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star, color: kYellowColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Bán chạy nhất',
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (vm.topProducts.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2, size: 48, color: colors.secondaryText),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có dữ liệu',
                      style: TextStyle(color: colors.secondaryText),
                    ),
                  ],
                ),
              ),
            )
          else
            ...vm.topProducts.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return _buildProductItem(index + 1, product, colors);
            }),
        ],
      ),
    );
  }

  Widget _buildProductItem(int rank, Map<String, dynamic> product, AppColors colors) {
    Color rankColor;
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700);
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0);
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32);
        break;
      default:
        rankColor = colors.secondaryText;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildProductImage(product['image'], 44, colors),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Đã bán: ${product['totalSold']}',
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency((product['revenue'] ?? 0).toInt()),
            style: const TextStyle(
              color: kGreenColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppColors colors) {
    final actions = [
      _QuickAction(icon: Icons.add_box, label: 'Thêm sản phẩm', color: kAccentColor),
      _QuickAction(icon: Icons.local_shipping, label: 'Xử lý đơn hàng', color: kGreenColor),
      _QuickAction(icon: Icons.percent, label: 'Tạo mã giảm giá', color: kYellowColor),
      _QuickAction(icon: Icons.bar_chart, label: 'Xem báo cáo', color: kPurpleColor),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thao tác nhanh',
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions.map((action) => _buildQuickActionButton(action, colors)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(_QuickAction action, AppColors colors) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: action.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, color: action.color, size: 20),
              const SizedBox(width: 10),
              Text(
                action.label,
                style: TextStyle(
                  color: action.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending': return kYellowColor;
      case 'confirmed': return kAccentColor;
      case 'processing': return Colors.indigo;
      case 'shipped': return Colors.cyan;
      case 'delivered': return kGreenColor;
      case 'completed': return kGreenColor;
      case 'cancelled': return kRedColor;
      case 'refunded': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending': return 'Chờ xác nhận';
      case 'confirmed': return 'Đã xác nhận';
      case 'processing': return 'Đang xử lý';
      case 'shipped': return 'Đang giao';
      case 'delivered': return 'Đã giao';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      case 'refunded': return 'Hoàn tiền';
      default: return status ?? '';
    }
  }
}

class _StatData {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String trend;
  final bool trendUp;

  _StatData({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendUp,
  });
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });
}

Widget _buildProductImage(dynamic image, double size, AppColors colors) {
  String imageUrl = '';
  if (image is List && image.isNotEmpty) {
    imageUrl = image.first.toString();
  } else if (image is String && image.isNotEmpty) {
    imageUrl = image;
  }
  
  if (imageUrl.startsWith('http')) {
    return Image.network(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: colors.background,
        child: Icon(Icons.image, color: colors.secondaryText, size: size * 0.5),
      ),
    );
  }
  return Container(
    width: size,
    height: size,
    color: colors.background,
    child: Icon(Icons.image, color: colors.secondaryText, size: size * 0.5),
  );
}
