import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/order_model.dart';
import '../view_models/order_view_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    
    try {
      final orderVM = context.read<OrderViewModel>();
      // First try to find in existing orders
      final existingOrder = orderVM.orders.where((o) => o.id == widget.orderId).firstOrNull;
      
      if (existingOrder != null) {
        setState(() {
          _order = existingOrder;
          _isLoading = false;
        });
      } else {
        // Load from API if not found
        await orderVM.loadOrders();
        final order = orderVM.orders.where((o) => o.id == widget.orderId).firstOrNull;
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải đơn hàng: $e'),
            backgroundColor: kRedColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Chi tiết đơn hàng', style: TextStyle(color: colors.primaryText)),
        elevation: 0,
        iconTheme: IconThemeData(color: colors.primaryText),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? _buildNotFound(colors)
              : _buildOrderDetail(colors),
    );
  }

  Widget _buildNotFound(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colors.secondaryText),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy đơn hàng',
            style: TextStyle(fontSize: 18, color: colors.secondaryText),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/orders'),
            style: ElevatedButton.styleFrom(backgroundColor: kAccentColor),
            child: const Text('Xem tất cả đơn hàng'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetail(AppColors colors) {
    final order = _order!;
    
    return RefreshIndicator(
      onRefresh: _loadOrder,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Container(
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
                      Text(
                        order.orderNumber.isNotEmpty ? order.orderNumber : order.id,
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
                    formatVietnamDateTime(order.createdAt),
                    style: TextStyle(color: colors.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Shipping address
            Container(
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
                      Icon(Icons.location_on_outlined, color: kAccentColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Địa chỉ giao hàng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.shippingAddress.fullName,
                    style: TextStyle(fontWeight: FontWeight.w500, color: colors.primaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.shippingAddress.phone,
                    style: TextStyle(color: colors.secondaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.shippingAddress.fullAddress,
                    style: TextStyle(color: colors.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Products
            Container(
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
                      Icon(Icons.shopping_bag_outlined, color: kAccentColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sản phẩm (${order.items.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.productImageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: colors.border,
                              child: const Icon(Icons.image),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: colors.primaryText,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'x${item.quantity}',
                                style: TextStyle(color: colors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatVND(item.price * item.quantity),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: colors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment info
            Container(
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
                      Icon(Icons.payment_outlined, color: kAccentColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Thanh toán',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentRow('Tạm tính', formatVND(order.subtotal), colors),
                  _buildPaymentRow('Phí vận chuyển', formatVND(order.shippingFee), colors),
                  if (order.tax > 0)
                    _buildPaymentRow('Thuế', formatVND(order.tax), colors),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng cộng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colors.primaryText,
                        ),
                      ),
                      Text(
                        formatVND(order.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: kAccentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phương thức: ${_getPaymentMethodText(order.paymentMethod)}',
                    style: TextStyle(color: colors.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            if (order.status == OrderStatus.pending || order.status == OrderStatus.confirmed)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(order, colors),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kRedColor,
                    side: const BorderSide(color: kRedColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Hủy đơn hàng'),
                ),
              ),
            if (order.status == OrderStatus.completed || order.status == OrderStatus.cancelled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleReorder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Đặt lại'),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, AppColors colors, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.secondaryText)),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? kGreenColor : colors.primaryText,
              fontWeight: FontWeight.w500,
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
      case OrderStatus.shipped:
        color = kPurpleColor;
        break;
      case OrderStatus.delivered:
      case OrderStatus.completed:
        color = kGreenColor;
        break;
      case OrderStatus.cancelled:
        color = kRedColor;
        break;
      case OrderStatus.refunded:
        color = Colors.grey;
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
      case OrderStatus.shipped:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.completed:
        return 'Hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.refunded:
        return 'Đã hoàn tiền';
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cod':
        return 'Thanh toán khi nhận hàng';
      case 'momo':
        return 'Ví MoMo';
      case 'bank':
        return 'Chuyển khoản ngân hàng';
      default:
        return method;
    }
  }

  void _showCancelDialog(OrderModel order, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: Text('Hủy đơn hàng', style: TextStyle(color: colors.primaryText)),
        content: Text(
          'Bạn có chắc muốn hủy đơn hàng ${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}?',
          style: TextStyle(color: colors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Không', style: TextStyle(color: colors.secondaryText)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final orderVM = context.read<OrderViewModel>();
              final success = await orderVM.cancelOrder(order.id);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã hủy đơn hàng'), backgroundColor: kGreenColor),
                  );
                  _loadOrder();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(orderVM.errorMessage ?? 'Không thể hủy đơn'), backgroundColor: kRedColor),
                  );
                }
              }
            },
            child: const Text('Hủy đơn', style: TextStyle(color: kRedColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReorder(OrderModel order) async {
    final orderVM = context.read<OrderViewModel>();
    final success = await orderVM.reorder(order.id);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm sản phẩm vào giỏ hàng'), backgroundColor: kGreenColor),
        );
        Navigator.pushNamed(context, '/cart');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(orderVM.errorMessage ?? 'Không thể đặt lại'), backgroundColor: kRedColor),
        );
      }
    }
  }
}
