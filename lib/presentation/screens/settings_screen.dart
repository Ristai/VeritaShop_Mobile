import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/local_notification_service.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/pin_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/custom_switch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _realtimeNotify = true;
  bool _soundEnabled = true;
  String _language = 'Tiếng Việt';
  final LocalNotificationService _notificationService = LocalNotificationService();

  @override
  void initState() {
    super.initState();
    // Refresh PIN status từ cloud khi vào Settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PinViewModel>().checkPinStatus();
      // Initialize notification service
      if (!kIsWeb) {
        _notificationService.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cài đặt',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tùy chỉnh ứng dụng theo ý muốn của bạn',
            style: TextStyle(color: colors.secondaryText),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Thông báo',
            Icons.notifications_outlined,
            [
              _buildSwitchTile(
                'Thông báo thời gian thực',
                'Nhận thông báo ngay khi có bình luận mới',
                _realtimeNotify,
                (value) => setState(() => _realtimeNotify = value),
              ),
              _buildSwitchTile(
                'Âm thanh thông báo',
                'Phát âm thanh khi có thông báo',
                _soundEnabled,
                (value) => setState(() => _soundEnabled = value),
              ),
              if (!kIsWeb) ...[
                _buildActionTile(
                  'Test thông báo ngay',
                  'Gửi thông báo test ngay lập tức',
                  Icons.send,
                  _testInstantNotification,
                ),
                _buildActionTile(
                  'Test thông báo lên lịch',
                  'Gửi thông báo sau 5 giây',
                  Icons.schedule,
                  _testScheduledNotification,
                ),
                _buildActionTile(
                  'Test thông báo đơn hàng',
                  'Gửi thông báo đặt hàng thành công',
                  Icons.shopping_bag,
                  _testOrderNotification,
                ),
                _buildActionTile(
                  'Test thông báo khuyến mãi',
                  'Gửi thông báo khuyến mãi',
                  Icons.local_offer,
                  _testPromoNotification,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _buildThemeSection(),
          const SizedBox(height: 16),
          _buildSecuritySection(),
          const SizedBox(height: 16),
          _buildSection(
            'Tài khoản',
            Icons.person_outline,
            [
              _buildActionTile(
                'Thông tin cá nhân',
                'Xem và chỉnh sửa thông tin tài khoản',
                Icons.chevron_right,
                () => _showSnackBar('Mở thông tin cá nhân'),
              ),
              _buildActionTile(
                'Đổi mật khẩu',
                'Cập nhật mật khẩu đăng nhập',
                Icons.chevron_right,
                () => _showSnackBar('Mở đổi mật khẩu'),
              ),
              _buildActionTile(
                'Liên kết tài khoản',
                'Google, Facebook, Apple',
                Icons.chevron_right,
                () => _showSnackBar('Mở liên kết tài khoản'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Dữ liệu & Bảo mật',
            Icons.security_outlined,
            [
              _buildActionTile(
                'Xuất dữ liệu',
                'Tải xuống tất cả dữ liệu của bạn',
                Icons.download_outlined,
                () => _showSnackBar('Đang xuất dữ liệu...'),
              ),
              _buildActionTile(
                'Xóa dữ liệu cache',
                'Giải phóng bộ nhớ đệm',
                Icons.delete_outline,
                () => _showClearCacheDialog(),
              ),
              _buildActionTile(
                'Chính sách bảo mật',
                'Xem chính sách bảo mật của chúng tôi',
                Icons.chevron_right,
                () => _showSnackBar('Mở chính sách bảo mật'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Hỗ trợ',
            Icons.help_outline,
            [
              _buildActionTile(
                'Trung tâm trợ giúp',
                'Tìm câu trả lời cho các câu hỏi thường gặp',
                Icons.chevron_right,
                () => _showSnackBar('Mở trung tâm trợ giúp'),
              ),
              _buildActionTile(
                'Liên hệ hỗ trợ',
                'Gửi yêu cầu hỗ trợ kỹ thuật',
                Icons.chevron_right,
                () => _showContactDialog(),
              ),
              _buildActionTile(
                'Đánh giá ứng dụng',
                'Cho chúng tôi biết ý kiến của bạn',
                Icons.star_outline,
                () => _showSnackBar('Mở trang đánh giá'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Thông tin',
            Icons.info_outline,
            [
              _buildInfoTile('Phiên bản', '1.0.0'),
              _buildInfoTile('Build', '2025.12.13'),
            ],
          ),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    final colors = AppColors.of(context);
    return Container(
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
                Icon(icon, color: kAccentColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: colors.border, height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    final colors = AppColors.of(context);
    final themeVM = context.watch<ThemeViewModel>();
    
    return Container(
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
                Icon(Icons.palette_outlined, color: kAccentColor, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Giao diện',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: colors.border, height: 1),
          CustomSwitchTile(
            title: 'Chế độ tối',
            subtitle: 'Sử dụng giao diện tối để bảo vệ mắt',
            value: themeVM.isDarkMode,
            onChanged: (value) => themeVM.setDarkMode(value),
          ),
          _buildSelectTile(
            'Ngôn ngữ',
            _language,
            ['Tiếng Việt', 'English'],
            (value) => setState(() => _language = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    final colors = AppColors.of(context);
    final pinVM = context.watch<PinViewModel>();

    return Container(
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
                Icon(Icons.lock_outline, color: kAccentColor, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Bảo mật ứng dụng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: colors.border, height: 1),
          CustomSwitchTile(
            title: 'Khóa bằng mã PIN',
            subtitle: 'Yêu cầu mã PIN khi mở ứng dụng',
            value: pinVM.isPinEnabled,
            onChanged: (value) => _togglePinLock(value, pinVM),
          ),
          if (pinVM.isPinEnabled)
            _buildActionTile(
              'Đổi mã PIN',
              'Thay đổi mã PIN hiện tại',
              Icons.chevron_right,
              () => _navigateToChangePIN(),
            ),
        ],
      ),
    );
  }

  Future<void> _togglePinLock(bool enable, PinViewModel pinVM) async {
    if (enable) {
      // Navigate to setup PIN
      final result = await Navigator.pushNamed(
        context,
        '/pin-setup',
        arguments: {'isRequired': false, 'isChangingPin': false},
      );

      // PIN setup screen sẽ tự bật PIN nếu thành công
      if (result == true) {
        _showSnackBar('Đã bật khóa bằng mã PIN');
      }
    } else {
      // Xác nhận tắt PIN
      _showDisablePinDialog(pinVM);
    }
  }

  void _navigateToChangePIN() {
    Navigator.pushNamed(
      context,
      '/pin-setup',
      arguments: {'isRequired': false, 'isChangingPin': true},
    );
  }

  void _showDisablePinDialog(PinViewModel pinVM) {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.lock_open, color: colors.yellow),
            const SizedBox(width: 12),
            const Text('Tắt khóa PIN'),
          ],
        ),
        content: const Text(
          'Bạn có chắc muốn tắt khóa bằng mã PIN?\n\n'
          'Ứng dụng sẽ không yêu cầu mã PIN khi mở.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Hủy', style: TextStyle(color: colors.secondaryText)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await pinVM.disablePin();
              if (mounted) {
                _showSnackBar('Đã tắt khóa bằng mã PIN');
              }
            },
            child: Text('Tắt', style: TextStyle(color: colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return CustomSwitchTile(
      title: title,
      subtitle: subtitle,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSelectTile(
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final colors = AppColors.of(context);
    return ListTile(
      title: Text(title),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          underline: const SizedBox.shrink(),
          isDense: true,
          dropdownColor: colors.card,
          items: options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData trailingIcon,
    VoidCallback onTap,
  ) {
    final colors = AppColors.of(context);
    return ListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: colors.secondaryText, fontSize: 12),
      ),
      trailing: Icon(trailingIcon, color: colors.secondaryText),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String label, String value) {
    final colors = AppColors.of(context);
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(color: colors.secondaryText),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(),
        icon: const Icon(Icons.logout, color: kRedColor),
        label: const Text('Đăng xuất'),
        style: OutlinedButton.styleFrom(
          foregroundColor: kRedColor,
          side: const BorderSide(color: kRedColor),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ==================== TEST NOTIFICATION METHODS ====================

  Future<void> _testInstantNotification() async {
    // Request permission first
    final hasPermission = await _notificationService.requestPermission();
    if (!hasPermission) {
      _showSnackBar('Vui lòng cấp quyền thông báo trong cài đặt');
      return;
    }

    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '🔔 Test Thông Báo',
      body: 'Đây là thông báo test ngay lập tức từ VeritaShop!',
      payload: 'test_instant',
      type: NotificationType.general,
    );
    _showSnackBar('Đã gửi thông báo!');
  }

  Future<void> _testScheduledNotification() async {
    final hasPermission = await _notificationService.requestPermission();
    if (!hasPermission) {
      _showSnackBar('Vui lòng cấp quyền thông báo trong cài đặt');
      return;
    }

    final scheduledTime = DateTime.now().add(const Duration(seconds: 5));
    await _notificationService.scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '⏰ Thông Báo Lên Lịch',
      body: 'Thông báo này được lên lịch trước 5 giây!',
      scheduledTime: scheduledTime,
      payload: 'test_scheduled',
      type: NotificationType.reminder,
    );
    _showSnackBar('Thông báo sẽ hiện sau 5 giây!');
  }

  Future<void> _testOrderNotification() async {
    final hasPermission = await _notificationService.requestPermission();
    if (!hasPermission) {
      _showSnackBar('Vui lòng cấp quyền thông báo trong cài đặt');
      return;
    }

    await _notificationService.notifyNewOrder('VTS20260104TEST');
    _showSnackBar('Đã gửi thông báo đơn hàng!');
  }

  Future<void> _testPromoNotification() async {
    final hasPermission = await _notificationService.requestPermission();
    if (!hasPermission) {
      _showSnackBar('Vui lòng cấp quyền thông báo trong cài đặt');
      return;
    }

    await _notificationService.notifyPromo(
      title: 'Giảm giá 50%!',
      description: 'Nhập mã SALE50 để được giảm 50% cho đơn hàng đầu tiên. Chỉ hôm nay!',
      promoCode: 'SALE50',
    );
    _showSnackBar('Đã gửi thông báo khuyến mãi!');
  }

  // ==================== END TEST NOTIFICATION METHODS ====================

  void _showClearCacheDialog() {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: const Text('Xóa dữ liệu cache'),
        content: const Text('Bạn có chắc muốn xóa tất cả dữ liệu cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Đã xóa dữ liệu cache');
            },
            child: const Text('Xóa', style: TextStyle(color: kRedColor)),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Liên hệ hỗ trợ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email, color: kAccentColor),
              title: const Text('Email'),
              subtitle: const Text('support@veritashop.com'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Mở ứng dụng email');
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: kGreenColor),
              title: const Text('Hotline'),
              subtitle: const Text('1900 xxxx'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Gọi điện hotline');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: kPurpleColor),
              title: const Text('Chat trực tuyến'),
              subtitle: const Text('Hỗ trợ 24/7'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Mở chat hỗ trợ');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Reset PIN state (không xóa PIN data - giữ lại cho lần login sau)
              final pinVM = context.read<PinViewModel>();
              pinVM.resetPinStateOnLogout();

              // Logout
              final authVM = context.read<AuthViewModel>();
              await authVM.logout();

              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('Đăng xuất', style: TextStyle(color: kRedColor)),
          ),
        ],
      ),
    );
  }
}
