import 'package:flutter/material.dart';

/// A safe network image widget that shows a placeholder on error
class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPlaceholder = Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey[400],
        size: (width ?? 100) * 0.4,
      ),
    );

    final defaultError = Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.grey[400],
        size: (width ?? 100) * 0.4,
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: errorWidget ?? defaultError,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? defaultPlaceholder;
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? defaultError;
        },
      ),
    );
  }
}
