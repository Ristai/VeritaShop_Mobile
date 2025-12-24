import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/coupon_model.dart';
import '../../data/repositories/coupon_repository.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/order_view_model.dart';
import '../widgets/custom_button.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().loadCartItems();
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
      final cartSummary = context.read<CartViewModel>().cartSummary;
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

    if (orderViewModel.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm địa chỉ giao hàng'),
          backgroundColor: kRedColor,
        ),
      );
      return;
    }

    final cartSummary = cartViewModel.cartSummary;
    if (cartSummary == null) return;

    final order = await orderViewModel.placeOrder(
      cartSummary: cartSummary,
      note: _noteController.text.trim(),
      couponCode: _appliedCoupon?.coupon.code,
    );

    if (order != null && mounted) {
      await cartViewModel.clearCart();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(order: order),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderViewModel.errorMessage ?? 'Đặt hàng thất bại'),
          backgroundColor: kRedColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Thanh toán', style: TextStyle(color: colors.primaryText)),
        elevation: 0,
        iconTheme: IconThemeData(color: colors.primaryText),
      ),
      body: Consumer2<CartViewModel, OrderViewModel>(
        builder: (context, cartViewModel, orderViewModel, _) {
          if (cartViewModel.cartSummary == null) {
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
                      _buildOrderItemsSection(cartViewModel.cartSummary!),
                      const SizedBox(height: 20),
                      _buildCouponSection(cartViewModel.cartSummary!),
                      const SizedBox(height: 20),
                      _buildNoteSection(),
                      const SizedBox(height: 20),
                      _buildSummarySection(cartViewModel.cartSummary!),
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
    final steps = ['Địa chỉ', 'Thanh toán', 'Xác nhận'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: kCardColor,
        border: Border(bottom: BorderSide(color: kBorderColor.withValues(alpha: 0.5))),
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
                      color: isActive ? kAccentColor : kCardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? kAccentColor : kBorderColor,
                      ),
                    ),
                    child: Center(
                      child: isActive && index < _currentStep
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : kSecondaryTextColor,
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
                      color: isActive ? kAccentColor : kSecondaryTextColor,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Container(
                  width: 40,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: index < _currentStep ? kAccentColor : kBorderColor,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAddressSection(OrderViewModel orderViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: kAccentColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Địa chỉ giao hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              orderViewModel.selectedAddress!.phone,
              style: const TextStyle(color: kSecondaryTextColor),
            ),
            const SizedBox(height: 4),
            Text(
              orderViewModel.selectedAddress!.fullAddress,
              style: const TextStyle(color: kSecondaryTextColor),
            ),
          ] else
            GestureDetector(
              onTap: () => _showAddAddressDialog(orderViewModel),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorderColor, style: BorderStyle.solid),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment, color: kAccentColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Phương thức thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                  color: isSelected ? kAccentColor.withValues(alpha: 0.1) : kBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? kAccentColor : kBorderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPaymentIcon(method),
                      color: isSelected ? kAccentColor : kSecondaryTextColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getPaymentLabel(method),
                      style: TextStyle(
                        color: isSelected ? kAccentColor : kPrimaryTextColor,
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
      case 'VNPay':
      case 'ZaloPay':
        return Icons.account_balance_wallet;
      case 'Thẻ tín dụng/ghi nợ':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentLabel(String method) {
    switch (method) {
      case 'COD':
        return 'Thanh toán khi nhận hàng (COD)';
      default:
        return method;
    }
  }

  Widget _buildOrderItemsSection(CartSummary cartSummary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                color: kBackgroundColor,
                child: const Icon(Icons.image, color: kSecondaryTextColor),
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
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'x${item.quantity}',
                  style: const TextStyle(color: kSecondaryTextColor),
                ),
              ],
            ),
          ),
          Text(
            '${(item.totalPrice / 1000).toStringAsFixed(0)}K đ',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_offer, color: kAccentColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Mã giảm giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                          'Giảm ${(_appliedCoupon!.discountAmount / 1000).toStringAsFixed(0)}K đ',
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
                    style: const TextStyle(color: kPrimaryTextColor),
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã giảm giá',
                      hintStyle: const TextStyle(color: kSecondaryTextColor),
                      filled: true,
                      fillColor: kBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorderColor),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.note, color: kAccentColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Ghi chú',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: const TextStyle(color: kPrimaryTextColor),
            decoration: InputDecoration(
              hintText: 'Ghi chú cho đơn hàng (tùy chọn)',
              hintStyle: const TextStyle(color: kSecondaryTextColor),
              filled: true,
              fillColor: kBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kBorderColor),
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
    final discount = _appliedCoupon?.discountAmount ?? 0;
    final total = cartSummary.total - discount;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Tạm tính', '${(cartSummary.subtotal / 1000).toStringAsFixed(0)}K đ'),
          const SizedBox(height: 8),
          _buildSummaryRow('Phí vận chuyển', '${(cartSummary.shippingFee / 1000).toStringAsFixed(0)}K đ'),
          const SizedBox(height: 8),
          _buildSummaryRow('Thuế (10%)', '${(cartSummary.tax / 1000).toStringAsFixed(0)}K đ'),
          if (_appliedCoupon != null) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Giảm giá (${_appliedCoupon!.coupon.code})',
              '-${(discount / 1000).toStringAsFixed(0)}K đ',
              isDiscount: true,
            ),
          ],
          const Divider(color: kBorderColor, height: 24),
          _buildSummaryRow(
            'Tổng cộng',
            '${(total / 1000).toStringAsFixed(0)}K đ',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDiscount ? kGreenColor : (isBold ? kPrimaryTextColor : kSecondaryTextColor),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? kGreenColor : (isBold ? kAccentColor : kPrimaryTextColor),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Consumer<OrderViewModel>(
      builder: (context, orderViewModel, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardColor,
            border: Border(
              top: BorderSide(color: kBorderColor.withValues(alpha: 0.5)),
            ),
          ),
          child: SafeArea(
            child: CustomButton(
              text: orderViewModel.isLoading ? 'Đang xử lý...' : 'Đặt hàng',
              onPressed: orderViewModel.isLoading ? null : _placeOrder,
              isLoading: orderViewModel.isLoading,
            ),
          ),
        );
      },
    );
  }

  void _showAddressBottomSheet(OrderViewModel orderViewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardColor,
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
              const Text(
                'Chọn địa chỉ giao hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                      color: isSelected ? kAccentColor.withValues(alpha: 0.1) : kBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? kAccentColor : kBorderColor,
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
                                    style: const TextStyle(fontWeight: FontWeight.w500),
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
                                style: const TextStyle(color: kSecondaryTextColor, fontSize: 13),
                              ),
                              Text(
                                address.fullAddress,
                                style: const TextStyle(color: kSecondaryTextColor, fontSize: 13),
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
      backgroundColor: kCardColor,
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
                        const Text(
                          'Thêm địa chỉ mới',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                            const Text('Đặt làm địa chỉ mặc định'),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: kPrimaryTextColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kSecondaryTextColor),
        filled: true,
        fillColor: kBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kBorderColor),
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
