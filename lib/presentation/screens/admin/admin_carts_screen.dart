import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../view_models/admin/admin_cart_view_model.dart';

class AdminCartsScreen extends StatefulWidget {
  const AdminCartsScreen({super.key});

  @override
  State<AdminCartsScreen> createState() => _AdminCartsScreenState();
}

class _AdminCartsScreenState extends State<AdminCartsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminCartViewModel>().loadCarts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(num amount) {
    return NumberFormat('#,###').format(amount.toInt()) + ' đ';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Consumer<AdminCartViewModel>(
      builder: (context, vm, _) {
        // If a cart is selected, show detail view
        if (vm.selectedCart != null && vm.selectedUserId != null) {
          return _buildCartDetailView(vm, colors);
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(colors, vm),
              const SizedBox(height: 24),

              // Filters
              _buildFilters(colors, vm),
              const SizedBox(height: 24),

              // Error message
              if (vm.error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: kRedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kRedColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: kRedColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Lỗi: ${vm.error}',
                          style: const TextStyle(color: kRedColor),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: kRedColor),
                        onPressed: () => vm.loadCarts(),
                      ),
                    ],
                  ),
                ),

              // Content
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator(color: kAccentColor))
                    : vm.carts.isEmpty
                        ? _buildEmptyState(colors)
                        : _buildCartsTable(vm, colors),
              ),

              // Pagination
              if (vm.pagination != null)
                _buildPagination(vm, colors),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppColors colors, AdminCartViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quản lý giỏ hàng',
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${vm.carts.length} khách hàng có sản phẩm trong giỏ',
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(AppColors colors, AdminCartViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, email khách hàng...',
                hintStyle: TextStyle(color: colors.secondaryText),
                prefixIcon: Icon(Icons.search, color: colors.secondaryText),
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: kAccentColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          vm.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) => vm.setSearchQuery(value),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () => vm.loadCarts(),
            icon: const Icon(Icons.refresh),
            label: const Text('Làm mới'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              side: BorderSide(color: colors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.card,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Không có giỏ hàng nào',
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hiện tại không có khách hàng nào có sản phẩm trong giỏ',
            style: TextStyle(color: colors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildCartsTable(AdminCartViewModel vm, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(colors.background),
            columns: [
              DataColumn(label: Text('Khách hàng', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Email', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Số SP', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold)), numeric: true),
              DataColumn(label: Text('Tổng tiền', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold)), numeric: true),
              DataColumn(label: Text('Thao tác', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
            ],
            rows: vm.carts.map((cart) {
              final user = cart['user'] as Map<String, dynamic>?;
              final itemCount = cart['itemCount'] ?? 0;
              final subtotal = cart['subtotal'] ?? 0;

              return DataRow(cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: user?['avatar'] != null && user!['avatar'].toString().isNotEmpty
                            ? NetworkImage(user['avatar'])
                            : null,
                        child: user?['avatar'] == null || user!['avatar'].toString().isEmpty
                            ? Text((user?['name'] ?? 'U')[0].toUpperCase(), style: const TextStyle(fontSize: 12))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(user?['name'] ?? 'N/A', style: TextStyle(color: colors.primaryText)),
                    ],
                  ),
                ),
                DataCell(Text(user?['email'] ?? 'N/A', style: TextStyle(color: colors.primaryText))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kAccentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: kAccentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    _formatCurrency(subtotal),
                    style: const TextStyle(
                      color: kAccentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconAction(
                        Icons.visibility,
                        kAccentColor,
                        () => vm.loadCartByUser(user?['_id'] ?? ''),
                        tooltip: 'Xem chi tiết',
                      ),
                      const SizedBox(width: 8),
                      _buildIconAction(
                        Icons.delete_sweep,
                        kRedColor,
                        () => _confirmClearCart(context, vm, cart),
                        tooltip: 'Xóa giỏ hàng',
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCartDetailView(AdminCartViewModel vm, AppColors colors) {
    final cart = vm.selectedCart!;
    final user = cart['user'] as Map<String, dynamic>?;
    final items = (cart['items'] as List?) ?? [];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and header
          Row(
            children: [
              IconButton(
                onPressed: () => vm.clearSelectedCart(),
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: colors.card,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giỏ hàng của ${user?['name'] ?? 'N/A'}',
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?['email'] ?? '',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () => _confirmClearCart(context, vm, cart, fromDetail: true),
                  icon: const Icon(Icons.delete_sweep, color: kRedColor),
                  label: const Text('Xóa tất cả', style: TextStyle(color: kRedColor)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kRedColor),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Cart items
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator(color: kAccentColor))
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 64, color: colors.secondaryText),
                            const SizedBox(height: 16),
                            Text('Giỏ hàng trống', style: TextStyle(color: colors.secondaryText, fontSize: 18)),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.border),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => Divider(color: colors.border),
                          itemBuilder: (context, index) {
                            final item = items[index] as Map<String, dynamic>;
                            return _buildCartItemTile(vm, item, colors);
                          },
                        ),
                      ),
          ),

          // Summary
          if (items.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng cộng (${cart['itemCount'] ?? items.length} sản phẩm)',
                    style: TextStyle(
                      color: colors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatCurrency(cart['subtotal'] ?? 0),
                    style: const TextStyle(
                      color: kAccentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartItemTile(AdminCartViewModel vm, Map<String, dynamic> item, AppColors colors) {
    final product = item['product'] as Map<String, dynamic>?;
    final images = (product?['images'] as List?) ?? [];
    final imageUrl = images.isNotEmpty ? images[0].toString() : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: colors.background,
                child: Icon(Icons.image, color: colors.secondaryText),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?['name'] ?? 'N/A',
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Màu: ${item['color']?['name'] ?? 'N/A'}',
                  style: TextStyle(color: colors.secondaryText, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(item['price'] ?? 0),
                  style: const TextStyle(
                    color: kAccentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: (item['quantity'] ?? 1) > 1
                      ? () async {
                          final success = await vm.updateCartItem(
                            vm.selectedUserId!,
                            item['_id'],
                            (item['quantity'] ?? 1) - 1,
                          );
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(vm.error ?? 'Lỗi'), backgroundColor: kRedColor),
                            );
                          }
                        }
                      : null,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${item['quantity'] ?? 1}',
                    style: TextStyle(
                      color: colors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () async {
                    final success = await vm.updateCartItem(
                      vm.selectedUserId!,
                      item['_id'],
                      (item['quantity'] ?? 1) + 1,
                    );
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(vm.error ?? 'Lỗi'), backgroundColor: kRedColor),
                      );
                    }
                  },
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kRedColor),
            onPressed: () => _confirmDeleteItem(context, vm, item),
          ),
        ],
      ),
    );
  }

  Widget _buildIconAction(IconData icon, Color color, VoidCallback onTap, {String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Widget _buildPagination(AdminCartViewModel vm, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: vm.currentPage > 1
                ? () => vm.loadCarts(page: vm.currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: colors.card,
              disabledBackgroundColor: colors.background,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              'Trang ${vm.currentPage} / ${vm.totalPages}',
              style: TextStyle(color: colors.primaryText),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: vm.currentPage < vm.totalPages
                ? () => vm.loadCarts(page: vm.currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: colors.card,
              disabledBackgroundColor: colors.background,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, AdminCartViewModel vm, Map<String, dynamic> item) {
    final colors = AppColors.of(context);
    final product = item['product'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kRedColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete, color: kRedColor),
            ),
            const SizedBox(width: 12),
            Text('Xóa sản phẩm', style: TextStyle(color: colors.primaryText)),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${product?['name'] ?? 'sản phẩm này'}" khỏi giỏ hàng?',
          style: TextStyle(color: colors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRedColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final success = await vm.deleteCartItem(vm.selectedUserId!, item['_id']);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa sản phẩm'), backgroundColor: kGreenColor),
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _confirmClearCart(BuildContext context, AdminCartViewModel vm, Map<String, dynamic> cart, {bool fromDetail = false}) {
    final colors = AppColors.of(context);
    final user = cart['user'] as Map<String, dynamic>?;
    final userId = fromDetail ? vm.selectedUserId! : (user?['_id'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kRedColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_sweep, color: kRedColor),
            ),
            const SizedBox(width: 12),
            Text('Xóa giỏ hàng', style: TextStyle(color: colors.primaryText)),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn xóa toàn bộ giỏ hàng của "${user?['name'] ?? 'khách hàng này'}"?',
          style: TextStyle(color: colors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRedColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final success = await vm.clearUserCart(userId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa giỏ hàng'), backgroundColor: kGreenColor),
                );
              }
            },
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }
}
