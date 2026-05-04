import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../view_models/admin/admin_product_view_model.dart';
import '../../../data/models/product_model.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _searchController = TextEditingController();
  String _viewMode = 'grid'; // 'grid' or 'table'

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminProductViewModel>().loadProducts();
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
    
    return Consumer<AdminProductViewModel>(
      builder: (context, vm, _) {
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
                        onPressed: () => vm.loadProducts(),
                      ),
                    ],
                  ),
                ),
              
              // Content
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator(color: kAccentColor))
                    : vm.products.isEmpty
                        ? _buildEmptyState(colors)
                        : _viewMode == 'grid'
                            ? _buildGridView(vm, colors)
                            : _buildTableView(vm, colors),
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

  Widget _buildHeader(AppColors colors, AdminProductViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng ${vm.products.length} sản phẩm',
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // View Toggle
        Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              _buildViewToggle(Icons.grid_view, 'grid', colors),
              _buildViewToggle(Icons.table_rows, 'table', colors),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showProductForm(context, vm),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Thêm sản phẩm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggle(IconData icon, String mode, AppColors colors) {
    final isSelected = _viewMode == mode;
    return InkWell(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? kAccentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : colors.secondaryText,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFilters(AppColors colors, AdminProductViewModel vm) {
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
                hintText: 'Tìm kiếm sản phẩm...',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: vm.selectedBrand,
                hint: Text('Thương hiệu', style: TextStyle(color: colors.secondaryText)),
                icon: Icon(Icons.keyboard_arrow_down, color: colors.secondaryText),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tất cả')),
                  DropdownMenuItem(value: 'iPhone', child: Text('iPhone')),
                  DropdownMenuItem(value: 'Samsung', child: Text('Samsung')),
                  DropdownMenuItem(value: 'Xiaomi', child: Text('Xiaomi')),
                  DropdownMenuItem(value: 'OPPO', child: Text('OPPO')),
                  DropdownMenuItem(value: 'Vivo', child: Text('Vivo')),
                  DropdownMenuItem(value: 'Other', child: Text('Khác')),
                ],
                onChanged: (value) => vm.setSelectedBrand(value),
              ),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () => vm.loadProducts(),
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
              Icons.inventory_2_outlined,
              size: 64,
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có sản phẩm nào',
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm sản phẩm đầu tiên để bắt đầu',
            style: TextStyle(color: colors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(AdminProductViewModel vm, AppColors colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1400
            ? 4
            : constraints.maxWidth > 1000
                ? 3
                : constraints.maxWidth > 600
                    ? 2
                    : 1;
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: vm.products.length,
          itemBuilder: (context, index) => _buildProductCard(vm.products[index], vm, colors),
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product, AdminProductViewModel vm, AppColors colors) {
    final stockColor = product.stock > 10
        ? kGreenColor
        : product.stock > 0
            ? kYellowColor
            : kRedColor;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    product.images.isNotEmpty ? product.images[0] : '',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: colors.background,
                      child: Center(
                        child: Icon(Icons.image, color: colors.secondaryText, size: 48),
                      ),
                    ),
                  ),
                ),
                // Stock Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.stock > 0 ? 'Còn ${product.stock}' : 'Hết hàng',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Brand Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.brand,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: kYellowColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _formatCurrency(product.price),
                          style: const TextStyle(
                            color: kAccentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _buildIconAction(
                            Icons.edit,
                            kAccentColor,
                            () => _showProductForm(context, vm, product: product),
                          ),
                          const SizedBox(width: 8),
                          _buildIconAction(
                            Icons.delete,
                            kRedColor,
                            () => _confirmDelete(context, vm, product),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconAction(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
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
    );
  }

  Widget _buildTableView(AdminProductViewModel vm, AppColors colors) {
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
              DataColumn(label: Text('Hình ảnh', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Tên sản phẩm', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Thương hiệu', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Giá', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold)), numeric: true),
              DataColumn(label: Text('Tồn kho', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold)), numeric: true),
              DataColumn(label: Text('Đánh giá', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Thao tác', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
            ],
            rows: vm.products.map((product) {
              final stockColor = product.stock > 10
                  ? kGreenColor
                  : product.stock > 0
                      ? kYellowColor
                      : kRedColor;
              
              return DataRow(cells: [
                DataCell(
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.images.isNotEmpty ? product.images[0] : '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: colors.background,
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.primaryText),
                    ),
                  ),
                ),
                DataCell(Text(product.brand, style: TextStyle(color: colors.primaryText))),
                DataCell(Text(_formatCurrency(product.price), style: const TextStyle(color: kAccentColor, fontWeight: FontWeight.bold))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.stock.toString(),
                      style: TextStyle(
                        color: stockColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: kYellowColor, size: 16),
                      const SizedBox(width: 4),
                      Text(product.rating.toStringAsFixed(1)),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: kAccentColor),
                        onPressed: () => _showProductForm(context, vm, product: product),
                        tooltip: 'Sửa',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: kRedColor),
                        onPressed: () => _confirmDelete(context, vm, product),
                        tooltip: 'Xóa',
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

  Widget _buildPagination(AdminProductViewModel vm, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: vm.currentPage > 1
                ? () => vm.loadProducts(page: vm.currentPage - 1)
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
                ? () => vm.loadProducts(page: vm.currentPage + 1)
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

  void _showProductForm(BuildContext context, AdminProductViewModel vm, {ProductModel? product}) {
    final colors = AppColors.of(context);
    final isEdit = product != null;
    final formKey = GlobalKey<FormState>();
    
    // Basic info controllers
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toInt().toString() ?? '');
    final originalPriceController = TextEditingController(text: product?.originalPrice?.toInt().toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final warrantyController = TextEditingController(text: product?.warranty ?? '12 tháng');
    
    // Specs controllers
    final ramController = TextEditingController(text: product?.specs.ram ?? '8GB');
    final romController = TextEditingController(text: product?.specs.rom ?? '256GB');
    final chipController = TextEditingController(text: product?.specs.chip ?? '');
    final batteryController = TextEditingController(text: product?.specs.battery ?? '5000mAh');
    final screenController = TextEditingController(text: product?.specs.screen ?? '');
    final cameraController = TextEditingController(text: product?.specs.camera ?? '');
    
    String selectedBrand = product?.brand ?? 'iPhone';
    String selectedCondition = product?.condition ?? 'new';
    bool isFeatured = product?.isFeatured ?? false;
    bool isLoading = false;
    String? errorMessage;
    
    // Image management
    List<String> uploadedImageUrls = List<String>.from(product?.images ?? []);
    bool isUploadingImage = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 700,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: kAccentColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kAccentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEdit ? Icons.edit : Icons.add_box,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới',
                                style: TextStyle(
                                  color: colors.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isEdit ? 'Cập nhật thông tin sản phẩm' : 'Điền đầy đủ thông tin sản phẩm',
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  
                  // Error message
                  if (errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: kRedColor.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: kRedColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: kRedColor, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Form content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Basic Info Section
                            _buildSectionTitle('Thông tin cơ bản', Icons.info_outline, colors),
                            const SizedBox(height: 16),
                            
                            _buildFormField('Tên sản phẩm *', nameController, colors, 
                              hint: 'VD: iPhone 15 Pro Max 256GB'),
                            const SizedBox(height: 16),
                            
                            _buildFormField('Mô tả *', descController, colors, 
                              maxLines: 3, hint: 'Mô tả chi tiết sản phẩm...'),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    'Thương hiệu *',
                                    selectedBrand,
                                    ['iPhone', 'Samsung', 'Xiaomi', 'OPPO', 'Vivo', 'Other'],
                                    (value) => setDialogState(() => selectedBrand = value!),
                                    colors,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdownField(
                                    'Tình trạng',
                                    selectedCondition,
                                    ['new', 'likenew', 'used'],
                                    (value) => setDialogState(() => selectedCondition = value!),
                                    colors,
                                    displayMap: {'new': 'Mới', 'likenew': 'Like New', 'used': 'Đã sử dụng'},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Price Section
                            _buildSectionTitle('Giá & Tồn kho', Icons.attach_money, colors),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField('Giá bán (VNĐ) *', priceController, colors, 
                                    isNumber: true, hint: 'VD: 25990000'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormField('Giá gốc (VNĐ)', originalPriceController, colors, 
                                    isNumber: true, hint: 'VD: 29990000'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField('Số lượng tồn kho *', stockController, colors, 
                                    isNumber: true, hint: 'VD: 50'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormField('Bảo hành', warrantyController, colors, 
                                    hint: 'VD: 12 tháng'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Specs Section
                            _buildSectionTitle('Thông số kỹ thuật', Icons.settings, colors),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField('RAM *', ramController, colors, hint: 'VD: 8GB'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormField('ROM *', romController, colors, hint: 'VD: 256GB'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField('Chip *', chipController, colors, hint: 'VD: A17 Pro'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFormField('Pin *', batteryController, colors, hint: 'VD: 5000mAh'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            _buildFormField('Màn hình *', screenController, colors, 
                              hint: 'VD: 6.7 inch Super Retina XDR OLED'),
                            const SizedBox(height: 16),
                            
                            _buildFormField('Camera *', cameraController, colors, 
                              hint: 'VD: 48MP + 12MP + 12MP'),
                            const SizedBox(height: 24),
                            
                            // Images Section
                            _buildSectionTitle('Hình ảnh', Icons.image, colors),
                            const SizedBox(height: 16),
                            
                            // Upload buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: isUploadingImage ? null : () async {
                                      final picker = ImagePicker();
                                      final images = await picker.pickMultiImage();
                                      if (images.isNotEmpty) {
                                        setDialogState(() => isUploadingImage = true);
                                        try {
                                          for (final image in images) {
                                            final bytes = await image.readAsBytes();
                                            final response = await ApiService.instance.uploadImage(
                                              bytes.toList(),
                                              image.name,
                                            );
                                            if (response['success'] == true) {
                                              uploadedImageUrls.add(response['data']['url']);
                                            }
                                          }
                                          setDialogState(() {});
                                        } catch (e) {
                                          setDialogState(() => errorMessage = 'Lỗi upload: $e');
                                        } finally {
                                          setDialogState(() => isUploadingImage = false);
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Chọn từ máy'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: BorderSide(color: kAccentColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: isUploadingImage ? null : () {
                                      _showAddUrlDialog(context, colors, (url) {
                                        if (url.isNotEmpty) {
                                          setDialogState(() => uploadedImageUrls.add(url));
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.link),
                                    label: const Text('Thêm URL'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: BorderSide(color: colors.border),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Loading indicator
                            if (isUploadingImage)
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Đang upload ảnh...'),
                                  ],
                                ),
                              ),
                            
                            // Image preview grid
                            if (uploadedImageUrls.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${uploadedImageUrls.length} ảnh',
                                      style: TextStyle(
                                        color: colors.secondaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: uploadedImageUrls.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final url = entry.value;
                                        return Stack(
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                border: index == 0 
                                                    ? Border.all(color: kAccentColor, width: 2)
                                                    : null,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  url,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Container(
                                                    color: colors.border,
                                                    child: const Icon(Icons.broken_image, size: 30),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -4,
                                              right: -4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setDialogState(() => uploadedImageUrls.removeAt(index));
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: const BoxDecoration(
                                                    color: kRedColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (index == 0)
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: kAccentColor,
                                                    borderRadius: const BorderRadius.vertical(
                                                      bottom: Radius.circular(6),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Chính',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.border, style: BorderStyle.solid),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 48, color: colors.secondaryText),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Chưa có ảnh nào',
                                      style: TextStyle(color: colors.secondaryText),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),
                            
                            // Featured checkbox
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.border),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isFeatured,
                                    onChanged: (value) => setDialogState(() => isFeatured = value ?? false),
                                    activeColor: kAccentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sản phẩm nổi bật',
                                          style: TextStyle(
                                            color: colors.primaryText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Hiển thị ở trang chủ và các vị trí nổi bật',
                                          style: TextStyle(
                                            color: colors.secondaryText,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Actions
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.card,
                      border: Border(top: BorderSide(color: colors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          child: const Text('Hủy'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            // Validate required fields
                            if (nameController.text.trim().isEmpty ||
                                descController.text.trim().isEmpty ||
                                priceController.text.trim().isEmpty ||
                                stockController.text.trim().isEmpty ||
                                ramController.text.trim().isEmpty ||
                                romController.text.trim().isEmpty ||
                                chipController.text.trim().isEmpty ||
                                batteryController.text.trim().isEmpty ||
                                screenController.text.trim().isEmpty ||
                                cameraController.text.trim().isEmpty ||
                                uploadedImageUrls.isEmpty) {
                              setDialogState(() => errorMessage = 'Vui lòng điền đầy đủ các trường bắt buộc (*)');
                              return;
                            }
                            
                            setDialogState(() {
                              isLoading = true;
                              errorMessage = null;
                            });
                            
                            final data = {
                              'name': nameController.text.trim(),
                              'description': descController.text.trim(),
                              'brand': selectedBrand,
                              'condition': selectedCondition,
                              'price': int.tryParse(priceController.text.trim()) ?? 0,
                              'originalPrice': int.tryParse(originalPriceController.text.trim()) ?? 0,
                              'stock': int.tryParse(stockController.text.trim()) ?? 0,
                              'warranty': warrantyController.text.trim(),
                              'isFeatured': isFeatured,
                              'specs': {
                                'ram': ramController.text.trim(),
                                'rom': romController.text.trim(),
                                'chip': chipController.text.trim(),
                                'battery': batteryController.text.trim(),
                                'screen': screenController.text.trim(),
                                'camera': cameraController.text.trim(),
                              },
                              'images': uploadedImageUrls,
                              'colors': product?.colors.isNotEmpty == true 
                                  ? product!.colors.map((c) => {'name': c.name, 'code': c.code}).toList()
                                  : [{'name': 'Mặc định', 'code': '#000000'}],
                            };

                            bool success;
                            if (isEdit) {
                              success = await vm.updateProduct(product.id, data);
                            } else {
                              success = await vm.createProduct(data);
                            }

                            if (success && context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEdit ? 'Đã cập nhật sản phẩm' : 'Đã thêm sản phẩm thành công'),
                                  backgroundColor: kGreenColor,
                                ),
                              );
                            } else {
                              setDialogState(() {
                                isLoading = false;
                                errorMessage = vm.error ?? 'Có lỗi xảy ra, vui lòng thử lại';
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isEdit ? 'Cập nhật' : 'Thêm sản phẩm'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon, AppColors colors) {
    return Row(
      children: [
        Icon(icon, color: kAccentColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
    AppColors colors, {
    Map<String, String>? displayMap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colors.secondaryText),
          border: InputBorder.none,
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(displayMap?[item] ?? item),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    AppColors colors, {
    int maxLines = 1,
    bool isNumber = false,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.secondaryText),
        hintText: hint,
        hintStyle: TextStyle(color: colors.secondaryText.withValues(alpha: 0.5), fontSize: 13),
        filled: true,
        fillColor: colors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccentColor),
        ),
      ),
    );
  }

  void _showAddUrlDialog(BuildContext context, AppColors colors, Function(String) onSubmit) {
    final urlController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kAccentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.link, color: kAccentColor),
            ),
            const SizedBox(width: 12),
            Text('Thêm ảnh từ URL', style: TextStyle(color: colors.primaryText)),
          ],
        ),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(
            labelText: 'URL hình ảnh',
            hintText: 'https://example.com/image.jpg',
            filled: true,
            fillColor: colors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                onSubmit(url);
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminProductViewModel vm, ProductModel product) {
    final colors = AppColors.of(context);
    
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
            Text('Xác nhận xóa', style: TextStyle(color: colors.primaryText)),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${product.name}"?',
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
              final success = await vm.deleteProduct(product.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa sản phẩm'),
                    backgroundColor: kGreenColor,
                  ),
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
