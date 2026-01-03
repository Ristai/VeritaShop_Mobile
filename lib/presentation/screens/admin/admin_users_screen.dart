import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../view_models/admin/admin_user_view_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminUserViewModel>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Consumer<AdminUserViewModel>(
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
                        onPressed: () => vm.loadUsers(),
                      ),
                    ],
                  ),
                ),

              // Content
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator(color: kAccentColor))
                    : vm.users.isEmpty
                        ? _buildEmptyState(colors)
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

  Widget _buildHeader(AppColors colors, AdminUserViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quản lý khách hàng',
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tổng ${vm.users.length} khách hàng',
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showUserForm(context, vm),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Thêm khách hàng'),
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

  Widget _buildFilters(AppColors colors, AdminUserViewModel vm) {
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
                hintText: 'Tìm kiếm theo tên, email, SĐT...',
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
            onPressed: () => vm.loadUsers(),
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
              Icons.people_outline,
              size: 64,
              color: colors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có khách hàng nào',
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm khách hàng đầu tiên để bắt đầu',
            style: TextStyle(color: colors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(AdminUserViewModel vm, AppColors colors) {
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
              DataColumn(label: Text('Avatar', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Tên', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Email', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('SĐT', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Ngày đăng ký', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Trạng thái', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Thao tác', style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold))),
            ],
            rows: vm.users.map((user) {
              final isActive = user['isActive'] ?? true;
              return DataRow(cells: [
                DataCell(
                  CircleAvatar(
                    backgroundImage: user['avatar'] != null && user['avatar'].toString().isNotEmpty
                        ? NetworkImage(user['avatar'])
                        : null,
                    child: user['avatar'] == null || user['avatar'].toString().isEmpty
                        ? Text((user['name'] ?? 'U')[0].toUpperCase())
                        : null,
                  ),
                ),
                DataCell(Text(user['name'] ?? '', style: TextStyle(color: colors.primaryText))),
                DataCell(Text(user['email'] ?? '', style: TextStyle(color: colors.primaryText))),
                DataCell(Text(user['phone'] ?? 'Chưa có', style: TextStyle(color: colors.primaryText))),
                DataCell(Text(_formatDate(user['createdAt']), style: TextStyle(color: colors.primaryText))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? kGreenColor.withValues(alpha: 0.1)
                          : kRedColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? 'Hoạt động' : 'Đã khóa',
                      style: TextStyle(
                        color: isActive ? kGreenColor : kRedColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconAction(
                        Icons.edit,
                        kAccentColor,
                        () => _showUserForm(context, vm, user: user),
                        tooltip: 'Sửa',
                      ),
                      const SizedBox(width: 4),
                      _buildIconAction(
                        Icons.lock_reset,
                        kYellowColor,
                        () => _confirmResetPassword(context, vm, user),
                        tooltip: 'Reset mật khẩu',
                      ),
                      const SizedBox(width: 4),
                      _buildIconAction(
                        isActive ? Icons.block : Icons.check_circle,
                        isActive ? kYellowColor : kGreenColor,
                        () async {
                          final success = await vm.toggleUserStatus(user['_id']);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isActive ? 'Đã khóa tài khoản' : 'Đã kích hoạt tài khoản',
                                ),
                                backgroundColor: kGreenColor,
                              ),
                            );
                          }
                        },
                        tooltip: isActive ? 'Khóa' : 'Kích hoạt',
                      ),
                      const SizedBox(width: 4),
                      _buildIconAction(
                        Icons.delete,
                        kRedColor,
                        () => _confirmDelete(context, vm, user),
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

  Widget _buildPagination(AdminUserViewModel vm, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: vm.currentPage > 1
                ? () => vm.loadUsers(page: vm.currentPage - 1)
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
                ? () => vm.loadUsers(page: vm.currentPage + 1)
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

  void _showUserForm(BuildContext context, AdminUserViewModel vm, {Map<String, dynamic>? user}) {
    final colors = AppColors.of(context);
    final isEdit = user != null;

    final nameController = TextEditingController(text: user?['name'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final phoneController = TextEditingController(text: user?['phone'] ?? '');
    final passwordController = TextEditingController();

    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kAccentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEdit ? Icons.edit : Icons.person_add,
                          color: kAccentColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? 'Sửa khách hàng' : 'Thêm khách hàng mới',
                              style: TextStyle(
                                color: colors.primaryText,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isEdit ? 'Cập nhật thông tin khách hàng' : 'Điền thông tin khách hàng mới',
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
                  const SizedBox(height: 24),

                  // Error message
                  if (errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: kRedColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
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

                  // Form fields
                  _buildFormField('Họ tên *', nameController, colors, hint: 'VD: Nguyễn Văn A'),
                  const SizedBox(height: 16),
                  _buildFormField('Email *', emailController, colors, hint: 'VD: email@example.com'),
                  const SizedBox(height: 16),
                  _buildFormField('Số điện thoại', phoneController, colors, hint: 'VD: 0901234567'),
                  if (!isEdit) ...[
                    const SizedBox(height: 16),
                    _buildFormField('Mật khẩu *', passwordController, colors, hint: 'Tối thiểu 6 ký tự', isPassword: true),
                  ],
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          // Validate
                          if (nameController.text.trim().isEmpty ||
                              emailController.text.trim().isEmpty ||
                              (!isEdit && passwordController.text.trim().isEmpty)) {
                            setDialogState(() => errorMessage = 'Vui lòng điền đầy đủ các trường bắt buộc (*)');
                            return;
                          }

                          if (!isEdit && passwordController.text.trim().length < 6) {
                            setDialogState(() => errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự');
                            return;
                          }

                          setDialogState(() {
                            isLoading = true;
                            errorMessage = null;
                          });

                          final data = {
                            'name': nameController.text.trim(),
                            'email': emailController.text.trim(),
                            'phone': phoneController.text.trim(),
                            if (!isEdit) 'password': passwordController.text.trim(),
                          };

                          bool success;
                          if (isEdit) {
                            success = await vm.updateUser(user['_id'], data);
                          } else {
                            success = await vm.createUser(data);
                          }

                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEdit ? 'Đã cập nhật khách hàng' : 'Đã thêm khách hàng'),
                                backgroundColor: kGreenColor,
                              ),
                            );
                          } else {
                            setDialogState(() {
                              isLoading = false;
                              errorMessage = vm.error ?? 'Có lỗi xảy ra';
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isEdit ? 'Cập nhật' : 'Thêm'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, AppColors colors, {
    String? hint,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
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

  void _confirmResetPassword(BuildContext context, AdminUserViewModel vm, Map<String, dynamic> user) {
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
                color: kYellowColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_reset, color: kYellowColor),
            ),
            const SizedBox(width: 12),
            Text('Reset mật khẩu', style: TextStyle(color: colors.primaryText)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc muốn reset mật khẩu cho "${user['name']}"?',
              style: TextStyle(color: colors.secondaryText),
            ),
            const SizedBox(height: 12),
            Text(
              'Mật khẩu mới sẽ được gửi đến email: ${user['email']}',
              style: TextStyle(color: colors.secondaryText, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kYellowColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final email = await vm.resetUserPassword(user['_id']);
              if (email != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã gửi mật khẩu mới đến $email'),
                    backgroundColor: kGreenColor,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(vm.error ?? 'Có lỗi xảy ra'),
                    backgroundColor: kRedColor,
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminUserViewModel vm, Map<String, dynamic> user) {
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc muốn xóa khách hàng "${user['name']}"?',
              style: TextStyle(color: colors.secondaryText),
            ),
            const SizedBox(height: 8),
            Text(
              'Hành động này không thể hoàn tác. Giỏ hàng của khách hàng cũng sẽ bị xóa.',
              style: TextStyle(color: kRedColor, fontSize: 13),
            ),
          ],
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
              final success = await vm.deleteUser(user['_id']);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa khách hàng'),
                    backgroundColor: kGreenColor,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(vm.error ?? 'Có lỗi xảy ra'),
                    backgroundColor: kRedColor,
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
