import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../widgets/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: kGreenColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: kGreenColor,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Đặt hàng thành công!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cảm ơn bạn đã mua hàng tại VeritaShop',
                style: TextStyle(
                  fontSize: 16,
                  color: kSecondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorderColor),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Mã đơn hàng', order.orderNumber.isNotEmpty ? order.orderNumber : order.id),
                    const Divider(color: kBorderColor, height: 24),
                    _buildInfoRow('Số sản phẩm', '${order.totalItems} sản phẩm'),
                    const Divider(color: kBorderColor, height: 24),
                    _buildInfoRow(
                      'Tổng tiền',
                      formatVND(order.total),
                      valueColor: kAccentColor,
                    ),
                    const Divider(color: kBorderColor, height: 24),
                    _buildInfoRow('Thanh toán', order.paymentMethod),
                    const Divider(color: kBorderColor, height: 24),
                    _buildInfoRow('Trạng thái', order.statusText, valueColor: kYellowColor),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
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
                        Icon(Icons.location_on, color: kAccentColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Địa chỉ giao hàng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.shippingAddress.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      order.shippingAddress.phone,
                      style: const TextStyle(color: kSecondaryTextColor),
                    ),
                    Text(
                      order.shippingAddress.fullAddress,
                      style: const TextStyle(color: kSecondaryTextColor),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                        Navigator.pushNamed(context, '/orders');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kAccentColor,
                        side: const BorderSide(color: kAccentColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Xem đơn hàng'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Tiếp tục mua',
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/products',
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: kSecondaryTextColor),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? kPrimaryTextColor,
          ),
        ),
      ],
    );
  }
}
