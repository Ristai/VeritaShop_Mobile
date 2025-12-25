import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
    return Consumer<AdminUserViewModel>(
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
                      'Quản lý khách hàng',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên, email, SĐT...',
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
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
                  ],
                ),
              ),
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.users.isEmpty
                        ? const Center(child: Text('Không có khách hàng'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Avatar')),
                                  DataColumn(label: Text('Tên')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('SĐT')),
                                  DataColumn(label: Text('Ngày đăng ký')),
                                  DataColumn(label: Text('Trạng thái')),
                                  DataColumn(label: Text('Thao tác')),
                                ],
                                rows: vm.users.map((user) {
                                  final isActive = user['isActive'] ?? true;
                                  return DataRow(cells: [
                                    DataCell(
                                      CircleAvatar(
                                        backgroundImage: user['avatar'] != null && user['avatar'].isNotEmpty
                                            ? NetworkImage(user['avatar'])
                                            : null,
                                        child: user['avatar'] == null || user['avatar'].isEmpty
                                            ? Text((user['name'] ?? 'U')[0].toUpperCase())
                                            : null,
                                      ),
                                    ),
                                    DataCell(Text(user['name'] ?? '')),
                                    DataCell(Text(user['email'] ?? '')),
                                    DataCell(Text(user['phone'] ?? 'Chưa có')),
                                    DataCell(Text(_formatDate(user['createdAt']))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isActive ? 'Hoạt động' : 'Đã khóa',
                                          style: TextStyle(
                                            color: isActive ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Switch(
                                        value: isActive,
                                        onChanged: (value) async {
                                          final success = await vm.toggleUserStatus(user['_id']);
                                          if (success && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  value ? 'Đã kích hoạt tài khoản' : 'Đã khóa tài khoản',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
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
                            ? () => vm.loadUsers(page: vm.currentPage - 1)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text('Trang ${vm.currentPage} / ${vm.totalPages}'),
                      IconButton(
                        onPressed: vm.currentPage < vm.totalPages
                            ? () => vm.loadUsers(page: vm.currentPage + 1)
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
}
