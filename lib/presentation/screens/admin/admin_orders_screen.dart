import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../view_models/admin/admin_order_view_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminOrderViewModel>().loadOrders();
    });
  }

  String _formatCurrency(int amount) {
    return NumberFormat('#,###').format(amount) + ' đ';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminOrderViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý đơn hàng',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Tất cả'),
                            selected: vm.selectedStatus == null,
                            onSelected: (_) => vm.setStatusFilter(null),
                          ),
                          const SizedBox(width: 8),
                          ...AdminOrderViewModel.statuses.map((status) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(vm.getStatusText(status)),
                                selected: vm.selectedStatus == status,
                                onSelected: (_) => vm.setStatusFilter(status),
                                backgroundColor: _getStatusColor(status).withOpacity(0.1),
                                selectedColor: _getStatusColor(status).withOpacity(0.3),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.orders.isEmpty
                        ? const Center(child: Text('Không có đơn hàng'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: vm.orders.length,
                            itemBuilder: (context, index) {
                              final order = vm.orders[index];
                              return _buildOrderCard(context, vm, order);
                            },
                          ),
              ),
              if (vm.pagination != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: vm.currentPage > 1
                            ? () => vm.loadOrders(page: vm.currentPage - 1)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text('Trang ${vm.currentPage} / ${vm.totalPages}'),
                      IconButton(
                        onPressed: vm.currentPage < vm.totalPages
                            ? () => vm.loadOrders(page: vm.currentPage + 1)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, AdminOrderViewModel vm, dynamic order) {
    final status = order['status'] as String?;
    final items = order['items'] as List? ?? [];
    final colors = AppColors.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(status).withValues(alpha: 0.1),
            child: Icon(
              Icons.shopping_bag,
              color: _getStatusColor(status),
            ),
          ),
          title: Text(
            order['orderNumber'] ?? '',
            style: TextStyle(fontWeight: FontWeight.bold, color: colors.primaryText),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order['user']?['name'] ?? 'Khách hàng', style: TextStyle(color: colors.secondaryText)),
              Text(
                _formatDate(order['createdAt']),
                style: TextStyle(fontSize: 12, color: colors.secondaryText),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency((order['total'] ?? order['totalAmount'] ?? 0).toInt()),
                style: TextStyle(fontWeight: FontWeight.bold, color: colors.primaryText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  vm.getStatusText(status ?? ''),
                  style: TextStyle(
                    fontSize: 11,
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...items.map((item) {
                  // Lấy ảnh: ưu tiên item['image'], sau đó product['images'][0] hoặc product['image']
                  String imageUrl = '';
                  if (item['image'] != null && item['image'].toString().isNotEmpty) {
                    imageUrl = item['image'].toString();
                  } else if (item['product'] != null) {
                    final productImages = item['product']['images'];
                    if (productImages is List && productImages.isNotEmpty) {
                      imageUrl = productImages.first.toString();
                    } else if (productImages is String) {
                      imageUrl = productImages;
                    } else if (item['product']['image'] != null) {
                      imageUrl = item['product']['image'].toString();
                    }
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: imageUrl.startsWith('http')
                            ? Image.network(
                                imageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image, size: 20),
                                ),
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, size: 20),
                              ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['product']?['name'] ?? 'Sản phẩm',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'SL: ${item['quantity']} x ${_formatCurrency((item['price'] ?? 0).toInt())}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                const Text('Địa chỉ giao hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${order['shippingAddress']?['fullName']} - ${order['shippingAddress']?['phone']}',
                ),
                Text(
                  '${order['shippingAddress']?['streetAddress']}, ${order['shippingAddress']?['ward']}, ${order['shippingAddress']?['district']}, ${order['shippingAddress']?['province']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                // Simple dropdown for status update
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: status,
                        decoration: InputDecoration(
                          labelText: 'Cập nhật trạng thái',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: AdminOrderViewModel.statuses.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(vm.getStatusText(s)),
                          );
                        }).toList(),
                        onChanged: (newStatus) async {
                          if (newStatus != null && newStatus != status) {
                            final success = await vm.updateOrderStatus(order['_id'], newStatus);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã cập nhật trạng thái')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    if (status == 'delivered' || status == 'completed') ...[
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xác nhận hoàn tiền'),
                              content: Text('Hoàn tiền ${_formatCurrency((order['total'] ?? 0).toInt())}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hoàn tiền')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final success = await vm.refundOrder(order['_id']);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã hoàn tiền')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.money_off, size: 18),
                        label: const Text('Hoàn tiền'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      ),
                    ],
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'processing': return Colors.indigo;
      case 'shipped': return Colors.cyan;
      case 'delivered': return Colors.green;
      case 'completed': return Colors.teal;
      case 'cancelled': return Colors.red;
      case 'refunded': return Colors.grey;
      default: return Colors.grey;
    }
  }
}
