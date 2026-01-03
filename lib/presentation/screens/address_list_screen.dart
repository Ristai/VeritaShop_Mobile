import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../view_models/order_view_model.dart';
import '../widgets/custom_button.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Địa chỉ giao hàng', style: TextStyle(color: colors.primaryText)),
        elevation: 0,
        iconTheme: IconThemeData(color: colors.primaryText),
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, orderViewModel, _) {
          if (orderViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderViewModel.addresses.isEmpty) {
            return _buildEmptyState(colors);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderViewModel.addresses.length,
            itemBuilder: (context, index) {
              final address = orderViewModel.addresses[index];
              return _buildAddressCard(address, orderViewModel, colors);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(context, null),
        backgroundColor: kAccentColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm địa chỉ', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80,
            color: colors.secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có địa chỉ nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm địa chỉ để thuận tiện khi thanh toán',
            style: TextStyle(
              fontSize: 14,
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address, OrderViewModel orderViewModel, AppColors colors) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: address.isDefault ? kAccentColor : colors.border,
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        address.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.primaryText,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kAccentColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Mặc định',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: colors.secondaryText),
                  color: colors.card,
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showAddressForm(context, address);
                        break;
                      case 'delete':
                        _showDeleteDialog(address, orderViewModel);
                        break;
                      case 'default':
                        _setAsDefault(address, orderViewModel);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: colors.primaryText),
                          const SizedBox(width: 8),
                          Text('Chỉnh sửa', style: TextStyle(color: colors.primaryText)),
                        ],
                      ),
                    ),
                    if (!address.isDefault)
                      PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 20, color: colors.primaryText),
                            const SizedBox(width: 8),
                            Text('Đặt mặc định', style: TextStyle(color: colors.primaryText)),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: kRedColor),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: kRedColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: colors.secondaryText),
                const SizedBox(width: 8),
                Text(
                  address.phone,
                  style: TextStyle(color: colors.secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 16, color: colors.secondaryText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.fullAddress,
                    style: TextStyle(color: colors.secondaryText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressForm(BuildContext context, AddressModel? existingAddress) {
    final colors = AppColors.of(context);
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController(text: existingAddress?.fullName ?? '');
    final phoneController = TextEditingController(text: existingAddress?.phone ?? '');
    final provinceController = TextEditingController(text: existingAddress?.province ?? '');
    final districtController = TextEditingController(text: existingAddress?.district ?? '');
    final wardController = TextEditingController(text: existingAddress?.ward ?? '');
    final streetController = TextEditingController(text: existingAddress?.streetAddress ?? '');
    bool isDefault = existingAddress?.isDefault ?? false;
    final isEditing = existingAddress != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.primaryText,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: colors.secondaryText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: fullNameController,
                          label: 'Họ và tên',
                          validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập họ tên' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: phoneController,
                          label: 'Số điện thoại',
                          keyboardType: TextInputType.phone,
                          validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập số điện thoại' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: provinceController,
                          label: 'Tỉnh/Thành phố',
                          validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập tỉnh/thành phố' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: districtController,
                          label: 'Quận/Huyện',
                          validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập quận/huyện' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: wardController,
                          label: 'Phường/Xã',
                          validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập phường/xã' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: streetController,
                          label: 'Địa chỉ chi tiết',
                          validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập địa chỉ' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: isDefault,
                              onChanged: (v) => setModalState(() => isDefault = v ?? false),
                              activeColor: kAccentColor,
                            ),
                            Text(
                              'Đặt làm địa chỉ mặc định',
                              style: TextStyle(color: colors.primaryText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: isEditing ? 'Cập nhật' : 'Lưu địa chỉ',
                          onPressed: () async {
                            if (formKey.currentState?.validate() == true) {
                              final orderViewModel = context.read<OrderViewModel>();

                              final address = AddressModel(
                                id: existingAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
                                userId: existingAddress?.userId ?? '',
                                fullName: fullNameController.text,
                                phone: phoneController.text,
                                province: provinceController.text,
                                district: districtController.text,
                                ward: wardController.text,
                                streetAddress: streetController.text,
                                isDefault: isDefault,
                                createdAt: existingAddress?.createdAt ?? DateTime.now(),
                              );

                              bool success;
                              if (isEditing) {
                                success = await orderViewModel.updateAddress(address);
                              } else {
                                success = await orderViewModel.addAddress(address);
                              }

                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? (isEditing ? 'Cập nhật địa chỉ thành công' : 'Thêm địa chỉ thành công')
                                          : 'Có lỗi xảy ra',
                                    ),
                                    backgroundColor: success ? kGreenColor : kRedColor,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final colors = AppColors.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: colors.primaryText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.secondaryText),
        filled: true,
        fillColor: colors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kAccentColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kRedColor),
        ),
      ),
    );
  }

  void _showDeleteDialog(AddressModel address, OrderViewModel orderViewModel) {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: Text('Xóa địa chỉ', style: TextStyle(color: colors.primaryText)),
        content: Text(
          'Bạn có chắc muốn xóa địa chỉ này?',
          style: TextStyle(color: colors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: colors.secondaryText)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await orderViewModel.deleteAddress(address.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Đã xóa địa chỉ' : 'Xóa địa chỉ thất bại'),
                    backgroundColor: success ? kGreenColor : kRedColor,
                  ),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: kRedColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _setAsDefault(AddressModel address, OrderViewModel orderViewModel) async {
    final updatedAddress = address.copyWith(isDefault: true);
    final success = await orderViewModel.updateAddress(updatedAddress);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đã đặt làm địa chỉ mặc định' : 'Có lỗi xảy ra'),
          backgroundColor: success ? kGreenColor : kRedColor,
        ),
      );
    }
  }
}
