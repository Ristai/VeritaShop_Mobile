import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';
import '../view_models/order_view_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Lịch sử đơn hàng', style: TextStyle(color: colors.primaryText)),
        elevation: 0,
        iconTheme: IconThemeData(color: colors.primaryText),
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, orderViewModel, _) {
          if (orderViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderViewModel.orders.isEmpty) {
            return _buildEmptyState(colors);
          }

          return RefreshIndicator(
            onRefresh: () => orderViewModel.loadOrders(),
            color: kAccentColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderViewModel.orders.length,
              itemBuilder: (context, index) {
                final order = orderViewModel.orders[index];
                return _buildOrderCard(order, orderViewModel, colors);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: colors.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn hàng nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đơn hàng của bạn sẽ xuất hiện ở đây',
            style: TextStyle(color: colors.secondaryText),
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
            child: const Text('Mua sắm ngay'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, OrderViewModel orderViewModel, AppColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: colors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
          ),
          Divider(color: colors.border, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...order.items.take(2).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              item.productImageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                height: 50,
                                color: colors.background,
                                child: Icon(Icons.image, size: 20, color: colors.secondaryText),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: TextStyle(fontSize: 13, color: colors.primaryText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'x${item.quantity}',
                                  style: TextStyle(
                                    color: colors.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(item.totalPrice / 1000).toStringAsFixed(0)}K đ',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: colors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (order.items.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${order.items.length - 2} sản phẩm khác',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: colors.border, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                      '${(order.total / 1000).toStringAsFixed(0)}K đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kAccentColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (order.status == OrderStatus.pending)
                      TextButton(
                        onPressed: () => _showCancelDialog(order, orderViewModel, colors),
                        child: const Text(
                          'Hủy đơn',
                          style: TextStyle(color: kRedColor),
                        ),
                      ),
                    OutlinedButton(
                      onPressed: () => _showOrderDetail(order, colors),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kAccentColor,
                        side: const BorderSide(color: kAccentColor),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Chi tiết'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = kYellowColor;
        break;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        color = kAccentColor;
        break;
      case OrderStatus.shipping:
        color = kPurpleColor;
        break;
      case OrderStatus.delivered:
        color = kGreenColor;
        break;
      case OrderStatus.cancelled:
        color = kRedColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showCancelDialog(OrderModel order, OrderViewModel orderViewModel, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: Text('Hủy đơn hàng', style: TextStyle(color: colors.primaryText)),
        content: Text('Bạn có chắc muốn hủy đơn hàng ${order.id}?', style: TextStyle(color: colors.secondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Không', style: TextStyle(color: colors.secondaryText)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await orderViewModel.cancelOrder(order.id);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã hủy đơn hàng'),
                    backgroundColor: kGreenColor,
                  ),
                );
              }
            },
            child: const Text('Hủy đơn', style: TextStyle(color: kRedColor)),
          ),
        ],
      ),
    );
  }

  void _showOrderDetail(OrderModel order, AppColors colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.id,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryText,
                      ),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(color: colors.secondaryText),
                ),
                const SizedBox(height: 24),
                Text(
                  'Địa chỉ giao hàng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.shippingAddress.fullName,
                        style: TextStyle(fontWeight: FontWeight.w500, color: colors.primaryText),
                      ),
                      Text(
                        order.shippingAddress.phone,
                        style: TextStyle(color: colors.secondaryText),
                      ),
                      Text(
                        order.shippingAddress.fullAddress,
                        style: TextStyle(color: colors.secondaryText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sản phẩm',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              item.productImageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: TextStyle(fontWeight: FontWeight.w500, color: colors.primaryText),
                                ),
                                Text(
                                  '${(item.price / 1000).toStringAsFixed(0)}K đ x ${item.quantity}',
                                  style: TextStyle(color: colors.secondaryText),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(item.totalPrice / 1000).toStringAsFixed(0)}K đ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kAccentColor,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Tạm tính', '${(order.subtotal / 1000).toStringAsFixed(0)}K đ', colors),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Phí vận chuyển', '${(order.shippingFee / 1000).toStringAsFixed(0)}K đ', colors),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Thuế', '${(order.tax / 1000).toStringAsFixed(0)}K đ', colors),
                      Divider(color: colors.border, height: 24),
                      _buildSummaryRow(
                        'Tổng cộng',
                        '${(order.total / 1000).toStringAsFixed(0)}K đ',
                        colors,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Phương thức thanh toán', order.paymentMethod, colors),
                if (order.note != null && order.note!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Ghi chú',
                    style: TextStyle(fontWeight: FontWeight.bold, color: colors.primaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.note!,
                    style: TextStyle(color: colors.secondaryText),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, AppColors colors, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? colors.primaryText : colors.secondaryText,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? kAccentColor : colors.primaryText,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
