import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double width;
  final double height;
  final Duration duration;

  const CustomSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.width = 52,
    this.height = 28,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.value) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged != null) {
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = widget.activeColor ?? kAccentColor;
    final inactiveColor = widget.inactiveColor ??
        (isDark ? const Color(0xFF3A3F5A) : const Color(0xFFE0E0E0));

    final thumbPadding = 3.0;
    final thumbSize = widget.height - (thumbPadding * 2);
    final slideDistance = widget.width - thumbSize - (thumbPadding * 2);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final backgroundColor = Color.lerp(
            inactiveColor,
            activeColor,
            _slideAnimation.value,
          )!;

          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Icons inside track
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: thumbPadding + 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Check icon (left side, shown when active)
                        Opacity(
                          opacity: _slideAnimation.value,
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        // X icon (right side, shown when inactive)
                        Opacity(
                          opacity: 1 - _slideAnimation.value,
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: (isDark ? Colors.white : Colors.black54)
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  left: thumbPadding + (slideDistance * _slideAnimation.value),
                  top: thumbPadding,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;
  final Color? activeColor;

  const CustomSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.leading,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(color: colors.secondaryText, fontSize: 12),
            )
          : null,
      trailing: CustomSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      ),
      onTap: onChanged != null ? () => onChanged!(!value) : null,
    );
  }
}
