import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../view_models/admin/admin_coupon_view_model.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminCouponViewModel>().loadCoupons();
    });
  }

  String _formatCurrency(int amount) {
    return NumberFormat('#,###').format(amount) + ' đ';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminCouponViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quản lý mã giảm giá',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCouponForm(context, vm),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm mã'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.coupons.isEmpty
                        ? const Center(child: Text('Chưa có mã giảm giá'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: vm.coupons.length,
                            itemBuilder: (context, index) {
                              final coupon = vm.coupons[index];
                              return _buildCouponCard(context, vm, coupon);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCouponCard(BuildContext context, AdminCouponViewModel vm, Map<String, dynamic> coupon) {
    final isActive = coupon['isActive'] ?? false;
    final discountType = coupon['discountType'] ?? 'percentage';
    final discountValue = coupon['discountValue'] ?? 0;
    final usageLimit = coupon['usageLimit'];
    final usedCount = coupon['usedCount'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Text(
                        coupon['code'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'Đang hoạt động' : 'Đã tắt',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showCouponForm(context, vm, coupon: coupon),
                      tooltip: 'Sửa',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, vm, coupon),
                      tooltip: 'Xóa',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              coupon['description'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  Icons.discount,
                  discountType == 'percentage'
                      ? 'Giảm $discountValue%'
                      : 'Giảm ${_formatCurrency(discountValue)}',
                ),
                if (coupon['minOrderAmount'] != null)
                  _buildInfoChip(
                    Icons.shopping_cart,
                    'Đơn tối thiểu: ${_formatCurrency(coupon['minOrderAmount'])}',
                  ),
                if (coupon['maxDiscountAmount'] != null && discountType == 'percentage')
                  _buildInfoChip(
                    Icons.money_off,
                    'Giảm tối đa: ${_formatCurrency(coupon['maxDiscountAmount'])}',
                  ),
                _buildInfoChip(
                  Icons.people,
                  usageLimit != null
                      ? 'Đã dùng: $usedCount/$usageLimit'
                      : 'Đã dùng: $usedCount (không giới hạn)',
                ),
                _buildInfoChip(
                  Icons.calendar_today,
                  '${_formatDate(coupon['startDate'])} - ${_formatDate(coupon['endDate'])}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  void _showCouponForm(BuildContext context, AdminCouponViewModel vm, {Map<String, dynamic>? coupon}) {
    final isEdit = coupon != null;
    final codeController = TextEditingController(text: coupon?['code'] ?? '');
    final descController = TextEditingController(text: coupon?['description'] ?? '');
    final valueController = TextEditingController(text: coupon?['discountValue']?.toString() ?? '');
    final minOrderController = TextEditingController(text: coupon?['minOrderAmount']?.toString() ?? '');
    final maxDiscountController = TextEditingController(text: coupon?['maxDiscountAmount']?.toString() ?? '');
    final usageLimitController = TextEditingController(text: coupon?['usageLimit']?.toString() ?? '');
    
    String discountType = coupon?['discountType'] ?? 'percentage';
    bool isActive = coupon?['isActive'] ?? true;
    DateTime startDate = coupon?['startDate'] != null 
        ? DateTime.parse(coupon!['startDate']) 
        : DateTime.now();
    DateTime endDate = coupon?['endDate'] != null 
        ? DateTime.parse(coupon!['endDate']) 
        : DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Sửa mã giảm giá' : 'Thêm mã giảm giá'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Mã giảm giá'),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: discountType,
                          decoration: const InputDecoration(labelText: 'Loại giảm giá'),
                          items: const [
                            DropdownMenuItem(value: 'percentage', child: Text('Phần trăm (%)')),
                            DropdownMenuItem(value: 'fixed', child: Text('Số tiền cố định')),
                          ],
                          onChanged: (value) => setState(() => discountType = value!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: valueController,
                          decoration: InputDecoration(
                            labelText: discountType == 'percentage' ? 'Phần trăm giảm' : 'Số tiền giảm',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minOrderController,
                          decoration: const InputDecoration(labelText: 'Đơn tối thiểu'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxDiscountController,
                          decoration: const InputDecoration(labelText: 'Giảm tối đa'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: usageLimitController,
                    decoration: const InputDecoration(
                      labelText: 'Giới hạn lượt dùng (để trống = không giới hạn)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Ngày bắt đầu'),
                          subtitle: Text(DateFormat('dd/MM/yyyy').format(startDate)),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) setState(() => startDate = date);
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Ngày kết thúc'),
                          subtitle: Text(DateFormat('dd/MM/yyyy').format(endDate)),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) setState(() => endDate = date);
                          },
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Kích hoạt'),
                    value: isActive,
                    onChanged: (value) => setState(() => isActive = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'code': codeController.text.toUpperCase(),
                  'description': descController.text,
                  'discountType': discountType,
                  'discountValue': int.tryParse(valueController.text) ?? 0,
                  'minOrderAmount': int.tryParse(minOrderController.text),
                  'maxDiscountAmount': int.tryParse(maxDiscountController.text),
                  'usageLimit': usageLimitController.text.isNotEmpty 
                      ? int.tryParse(usageLimitController.text) 
                      : null,
                  'startDate': startDate.toIso8601String(),
                  'endDate': endDate.toIso8601String(),
                  'isActive': isActive,
                };

                bool success;
                if (isEdit) {
                  success = await vm.updateCoupon(coupon['_id'], data);
                } else {
                  success = await vm.createCoupon(data);
                }

                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Đã cập nhật mã giảm giá' : 'Đã thêm mã giảm giá')),
                  );
                }
              },
              child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminCouponViewModel vm, Map<String, dynamic> coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa mã "${coupon['code']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await vm.deleteCoupon(coupon['_id']);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa mã giảm giá')),
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
