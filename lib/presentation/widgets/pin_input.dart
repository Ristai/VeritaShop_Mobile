import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// Widget nhập PIN với bàn phím số
/// Hỗ trợ 4-6 chữ số, shake animation khi sai
class PinInput extends StatefulWidget {
  final int pinLength;
  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final bool showError;
  final String? errorMessage;
  final bool enabled;

  const PinInput({
    super.key,
    this.pinLength = 6,
    required this.onCompleted,
    this.onChanged,
    this.showError = false,
    this.errorMessage,
    this.enabled = true,
  });

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void didUpdateWidget(PinInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showError && !oldWidget.showError) {
      _triggerShakeAnimation();
    }
  }

  void _triggerShakeAnimation() {
    HapticFeedback.mediumImpact();
    _shakeController.forward().then((_) {
      _shakeController.reverse();
      setState(() => _pin = '');
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    if (!widget.enabled) return;
    if (_pin.length < widget.pinLength) {
      HapticFeedback.lightImpact();
      setState(() => _pin += key);
      widget.onChanged?.call(_pin);

      if (_pin.length == widget.pinLength) {
        widget.onCompleted(_pin);
      }
    }
  }

  void _onBackspace() {
    if (!widget.enabled) return;
    if (_pin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
      widget.onChanged?.call(_pin);
    }
  }

  void clearPin() {
    setState(() => _pin = '');
    widget.onChanged?.call(_pin);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN dots
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.pinLength,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _pin.length
                      ? (widget.showError ? colors.red : colors.accent)
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.showError
                        ? colors.red
                        : (index < _pin.length ? colors.accent : colors.border),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Error message
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: widget.showError && widget.errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    widget.errorMessage!,
                    style: TextStyle(
                      color: colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 40),

        // Numeric keypad
        _buildKeypad(colors),
      ],
    );
  }

  Widget _buildKeypad(AppColors colors) {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3'], colors),
        const SizedBox(height: 16),
        _buildKeypadRow(['4', '5', '6'], colors),
        const SizedBox(height: 16),
        _buildKeypadRow(['7', '8', '9'], colors),
        const SizedBox(height: 16),
        _buildKeypadRow(['', '0', 'backspace'], colors),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> keys, AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }

        if (key == 'backspace') {
          return _buildKeypadButton(
            onTap: _onBackspace,
            child: Icon(
              Icons.backspace_outlined,
              color: widget.enabled ? colors.primaryText : colors.secondaryText,
              size: 24,
            ),
            colors: colors,
          );
        }

        return _buildKeypadButton(
          onTap: () => _onKeyPressed(key),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: widget.enabled ? colors.primaryText : colors.secondaryText,
            ),
          ),
          colors: colors,
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton({
    required VoidCallback onTap,
    required Widget child,
    required AppColors colors,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: colors.card,
        shape: CircleBorder(side: BorderSide(color: colors.border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 80,
            height: 80,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
