import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/address_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/coupon_model.dart';
import '../../data/repositories/coupon_repository.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/order_view_model.dart';
import '../view_models/pin_view_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/pin_input.dart';
import 'order_success_screen.dart';
import 'payment_processing_screen.dart';

/// Model để truyền thông tin sản phẩm khi Buy Now
class DirectCheckoutItem {
  final String productId;
  final String productName;
  final String productImageUrl;
  final double price;
  final int quantity;
  final Map<String, dynamic> color;

  DirectCheckoutItem({
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.price,
    required this.quantity,
    required this.color,
  });

  /// Chuyển đổi thành CartModel để sử dụng trong checkout
  CartModel toCartModel() {
    return CartModel(
      id: 'direct_${DateTime.now().millisecondsSinceEpoch}',
      userId: '',
      productId: productId,
      productName: productName,
      productImageUrl: productImageUrl,
      price: price,
      quantity: quantity,
      color: CartColor(
        name: color['name'] ?? 'Mặc định',
        code: color['hex'],
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Tạo CartSummary từ direct item
  CartSummary toCartSummary() {
    return CartSummary.fromItems([toCartModel()]);
  }
}

class CheckoutScreen extends StatefulWidget {
  /// Sản phẩm mua ngay (nếu có). Nếu null, sử dụng giỏ hàng.
  final DirectCheckoutItem? directCheckoutItem;

  const CheckoutScreen({super.key, this.directCheckoutItem});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _noteController = TextEditingController();
  final _couponController = TextEditingController();
  final CouponRepository _couponRepository = CouponRepository();
  int _currentStep = 0;
  AppliedCoupon? _appliedCoupon;
  bool _isApplyingCoupon = false;
  String? _couponError;

  /// CartSummary cho direct checkout (Buy Now)
  CartSummary? _directCartSummary;

  /// Kiểm tra xem đang ở chế độ direct checkout hay không
  bool get _isDirectCheckout => widget.directCheckoutItem != null;

  /// Lấy CartSummary phù hợp (direct hoặc từ giỏ hàng)
  CartSummary? _getCartSummary(CartViewModel cartViewModel) {
    if (_isDirectCheckout) {
      return _directCartSummary;
    }
    return cartViewModel.cartSummary;
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo CartSummary cho direct checkout
    if (_isDirectCheckout) {
      _directCartSummary = widget.directCheckoutItem!.toCartSummary();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Chỉ load cart items nếu không phải direct checkout
      if (!_isDirectCheckout) {
        context.read<CartViewModel>().loadCartItems();
      }
      context.read<OrderViewModel>().loadAddresses();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      setState(() => _couponError = 'Vui lòng nhập mã giảm giá');
      return;
    }

    setState(() {
      _isApplyingCoupon = true;
      _couponError = null;
    });

    try {
      final cartSummary = _getCartSummary(context.read<CartViewModel>());
      final result = await _couponRepository.applyCoupon(code, cartSummary?.subtotal ?? 0);

      if (result != null) {
        setState(() => _appliedCoupon = result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Áp dụng mã ${result.coupon.code} thành công!'),
              backgroundColor: kGreenColor,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _couponError = e.toString());
    } finally {
      setState(() => _isApplyingCoupon = false);
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponController.clear();
      _couponError = null;
    });
  }

  Future<void> _placeOrder() async {
    final cartViewModel = context.read<CartViewModel>();
    final orderViewModel = context.read<OrderViewModel>();
    final pinViewModel = context.read<PinViewModel>();

    if (orderViewModel.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm địa chỉ giao hàng'),
          backgroundColor: kRedColor,
        ),
      );
      return;
    }

    // Kiểm tra nếu user đã bật PIN, yêu cầu xác thực
    if (pinViewModel.isPinEnabled) {
      final verified = await _showPinVerificationDialog();
      if (!verified) return; // User hủy hoặc nhập sai
    }

    final cartSummary = _getCartSummary(cartViewModel);
    if (cartSummary == null) return;

    final order = await orderViewModel.placeOrder(
      cartSummary: cartSummary,
      note: _noteController.text.trim(),
      couponCode: _appliedCoupon?.coupon.code,
    );

    if (order != null && mounted) {
      // Nếu là MoMo payment, chuyển đến màn hình xử lý thanh toán
      if (orderViewModel.selectedPaymentMethod == 'MoMo') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentProcessingScreen(order: order),
          ),
        );
      } else {
        // COD - clear cart (chỉ khi không phải direct checkout) và chuyển đến màn hình thành công
        if (!_isDirectCheckout) {
          await cartViewModel.clearCart();
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(order: order),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderViewModel.errorMessage ?? 'Đặt hàng thất bại'),
          backgroundColor: kRedColor,
        ),
      );
    }
  }

  /// Hiển thị bottom sheet xác thực PIN
  /// Trả về true nếu user nhập đúng PIN, false nếu hủy hoặc sai
  Future<bool> _showPinVerificationDialog() async {
    final colors = AppColors.of(context);
    final pinViewModel = context.read<PinViewModel>();
    bool showError = false;
    String? errorMessage;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Icon và title
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: kAccentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: kAccentColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Xác thực đặt hàng',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhập mã PIN để xác nhận đặt hàng',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // PIN Input
                    PinInput(
                      pinLength: 6,
                      showError: showError,
                      errorMessage: errorMessage,
                      onCompleted: (pin) async {
                        final isValid = await pinViewModel.verifyPin(pin);
                        if (isValid) {
                          Navigator.of(dialogContext).pop(true);
                        } else {
                          setModalState(() {
                            showError = true;
                            errorMessage = 'Mã PIN không đúng. Còn ${pinViewModel.remainingAttempts} lần thử';
                          });
                          // Reset error sau 2 giây
                          Future.delayed(const Duration(seconds: 2), () {
                            if (context.mounted) {
                              setModalState(() {
                                showError = false;
                                errorMessage = null;
                              });
                            }
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Nút hủy
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(
          _isDirectCheckout ? 'Mua ngay' : 'Thanh toán',
          style: TextStyle(color: colors.primaryText),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: colors.primaryText),
      ),
      body: Consumer2<CartViewModel, OrderViewModel>(
        builder: (context, cartViewModel, orderViewModel, _) {
          final cartSummary = _getCartSummary(cartViewModel);
          if (cartSummary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildStepIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddressSection(orderViewModel),
                      const SizedBox(height: 20),
                      _buildPaymentMethodSection(orderViewModel),
                      const SizedBox(height: 20),
                      _buildOrderItemsSection(cartSummary),
                      const SizedBox(height: 20),
                      _buildCouponSection(cartSummary),
                      const SizedBox(height: 20),
                      _buildNoteSection(),
                      const SizedBox(height: 20),
                      _buildSummarySection(cartSummary),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStepIndicator() {
    final colors = AppColors.of(context);
    final steps = ['Địa chỉ', 'Thanh toán', 'Xác nhận'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isLast = index == steps.length - 1;
          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isActive ? kAccentColor : colors.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? kAccentColor : colors.border,
                      ),
                    ),
                    child: Center(
                      child: isActive && index < _currentStep
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : colors.secondaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? kAccentColor : colors.secondaryText,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Container(
                  width: 40,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: index < _currentStep ? kAccentColor : colors.border,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAddressSection(OrderViewModel orderViewModel) {
    final colors = AppColors.of(context);
    return Container(
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
              const Icon(Icons.location_on, color: kAccentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Địa chỉ giao hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showAddressBottomSheet(orderViewModel),
                child: const Text(
                  'Thay đổi',
                  style: TextStyle(color: kAccentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (orderViewModel.selectedAddress != null) ...[
            Text(
              orderViewModel.selectedAddress!.fullName,
              style: TextStyle(fontWeight: FontWeight.w500, color: colors.primaryText),
            ),
            const SizedBox(height: 4),
            Text(
              orderViewModel.selectedAddress!.phone,
              style: TextStyle(color: colors.secondaryText),
            ),
            const SizedBox(height: 4),
            Text(
              orderViewModel.selectedAddress!.fullAddress,
              style: TextStyle(color: colors.secondaryText),
            ),
          ] else
            GestureDetector(
              onTap: () => _showAddAddressDialog(orderViewModel),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border, style: BorderStyle.solid),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: kAccentColor),
                    SizedBox(width: 8),
                    Text(
                      'Thêm địa chỉ mới',
                      style: TextStyle(color: kAccentColor),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(OrderViewModel orderViewModel) {
    final colors = AppColors.of(context);
    return Container(
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
              const Icon(Icons.payment, color: kAccentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Phương thức thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...orderViewModel.paymentMethods.map((method) {
            final isSelected = method == orderViewModel.selectedPaymentMethod;
            return GestureDetector(
              onTap: () => orderViewModel.selectPaymentMethod(method),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? kAccentColor.withValues(alpha: 0.1) : colors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? kAccentColor : colors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPaymentIcon(method),
                      color: isSelected ? kAccentColor : colors.secondaryText,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getPaymentLabel(method),
                      style: TextStyle(
                        color: isSelected ? kAccentColor : colors.primaryText,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: kAccentColor, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'COD':
        return Icons.local_shipping;
      case 'MoMo':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentLabel(String method) {
    switch (method) {
      case 'COD':
        return 'Thanh toán khi nhận hàng (COD)';
      case 'MoMo':
        return 'Ví MoMo';
      default:
        return method;
    }
  }

  Widget _buildOrderItemsSection(CartSummary cartSummary) {
    final colors = AppColors.of(context);
    return Container(
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
              const Icon(Icons.shopping_bag, color: kAccentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sản phẩm (${cartSummary.itemCount})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...cartSummary.items.map((item) => _buildOrderItem(item)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartModel item) {
    final colors = AppColors.of(context);
    return Padding(
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
                color: colors.background,
                child: Icon(Icons.image, color: colors.secondaryText),
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
                  style: TextStyle(fontWeight: FontWeight.w500, color: colors.primaryText),
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
            formatVND(item.totalPrice),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kAccentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(CartSummary cartSummary) {
    final colors = AppColors.of(context);
    return Container(
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
              const Icon(Icons.local_offer, color: kAccentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Mã giảm giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_appliedCoupon != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kGreenColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGreenColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: kGreenColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appliedCoupon!.coupon.code,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kGreenColor,
                          ),
                        ),
                        Text(
                          'Giảm ${formatVND(_appliedCoupon!.discountAmount)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: kGreenColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _removeCoupon,
                    icon: const Icon(Icons.close, color: kRedColor, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    style: TextStyle(color: colors.primaryText),
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã giảm giá',
                      hintStyle: TextStyle(color: colors.secondaryText),
                      filled: true,
                      fillColor: colors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isApplyingCoupon ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isApplyingCoupon
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Áp dụng', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          if (_couponError != null) ...[
            const SizedBox(height: 8),
            Text(
              _couponError!,
              style: const TextStyle(color: kRedColor, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    final colors = AppColors.of(context);
    return Container(
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
              const Icon(Icons.note, color: kAccentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ghi chú',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(color: colors.primaryText),
            decoration: InputDecoration(
              hintText: 'Ghi chú cho đơn hàng (tùy chọn)',
              hintStyle: TextStyle(color: colors.secondaryText),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(CartSummary cartSummary) {
    final colors = AppColors.of(context);
    final discount = _appliedCoupon?.discountAmount ?? 0;
    final total = cartSummary.total - discount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Tạm tính', formatVND(cartSummary.subtotal)),
          const SizedBox(height: 8),
          _buildSummaryRow('Phí vận chuyển', formatVND(cartSummary.shippingFee)),
          const SizedBox(height: 8),
          _buildSummaryRow('Thuế (10%)', formatVND(cartSummary.tax)),
          if (_appliedCoupon != null) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Giảm giá (${_appliedCoupon!.coupon.code})',
              formatVNDDiscount(discount),
              isDiscount: true,
            ),
          ],
          Divider(color: colors.border, height: 24),
          _buildSummaryRow(
            'Tổng cộng',
            formatVND(total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDiscount ? kGreenColor : (isBold ? colors.primaryText : colors.secondaryText),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? kGreenColor : (isBold ? kAccentColor : colors.primaryText),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final colors = AppColors.of(context);
    return Consumer<OrderViewModel>(
      builder: (context, orderViewModel, _) {
        final isMoMo = orderViewModel.selectedPaymentMethod == 'MoMo';
        final buttonText = orderViewModel.isLoading
            ? 'Đang xử lý...'
            : (isMoMo ? 'Thanh toán với MoMo' : 'Đặt hàng');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            border: Border(
              top: BorderSide(color: colors.border.withValues(alpha: 0.5)),
            ),
          ),
          child: SafeArea(
            child: CustomButton(
              text: buttonText,
              onPressed: orderViewModel.isLoading ? null : _placeOrder,
              isLoading: orderViewModel.isLoading,
            ),
          ),
        );
      },
    );
  }

  void _showAddressBottomSheet(OrderViewModel orderViewModel) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn địa chỉ giao hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              ...orderViewModel.addresses.map((address) {
                final isSelected = address.id == orderViewModel.selectedAddress?.id;
                return GestureDetector(
                  onTap: () {
                    orderViewModel.selectAddress(address);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? kAccentColor.withValues(alpha: 0.1) : colors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? kAccentColor : colors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    address.fullName,
                                    style: TextStyle(fontWeight: FontWeight.w500, color: colors.primaryText),
                                  ),
                                  if (address.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kAccentColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Mặc định',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                address.phone,
                                style: TextStyle(color: colors.secondaryText, fontSize: 13),
                              ),
                              Text(
                                address.fullAddress,
                                style: TextStyle(color: colors.secondaryText, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: kAccentColor),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Thêm địa chỉ mới',
                onPressed: () {
                  Navigator.pop(context);
                  _showAddAddressDialog(orderViewModel);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddAddressDialog(OrderViewModel orderViewModel) {
    final colors = AppColors.of(context);
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    final provinceController = TextEditingController();
    final districtController = TextEditingController();
    final wardController = TextEditingController();
    final streetController = TextEditingController();
    bool isDefault = orderViewModel.addresses.isEmpty;

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
                        Text(
                          'Thêm địa chỉ mới',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryText,
                          ),
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
                            Text('Đặt làm địa chỉ mặc định', style: TextStyle(color: colors.primaryText)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'Lưu địa chỉ',
                          onPressed: () async {
                            if (formKey.currentState?.validate() == true) {
                              final address = AddressModel(
                                id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                                userId: 'demo_user',
                                fullName: fullNameController.text,
                                phone: phoneController.text,
                                province: provinceController.text,
                                district: districtController.text,
                                ward: wardController.text,
                                streetAddress: streetController.text,
                                isDefault: isDefault,
                                createdAt: DateTime.now(),
                              );
                              await orderViewModel.addAddress(address);
                              if (mounted) Navigator.pop(context);
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
}
