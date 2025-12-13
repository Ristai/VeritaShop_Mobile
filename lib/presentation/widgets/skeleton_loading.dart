import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                kCardColor,
                kBorderColor,
                kCardColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoading(
            height: 120,
            borderRadius: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoading(height: 16, width: 100),
                const SizedBox(height: 8),
                const SkeletonLoading(height: 14),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SkeletonLoading(height: 18, width: 80),
                    SkeletonLoading(
                      height: 32,
                      width: 32,
                      borderRadius: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool isGrid;

  const ProductListSkeleton({
    super.key,
    this.itemCount = 6,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => const ProductCardSkeleton(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ProductCardSkeleton(),
      ),
    );
  }
}

class ReviewSkeleton extends StatelessWidget {
  const ReviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
              const SkeletonLoading(
                width: 40,
                height: 40,
                borderRadius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLoading(height: 14, width: 100),
                    SizedBox(height: 4),
                    SkeletonLoading(height: 12, width: 150),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonLoading(height: 14),
          const SizedBox(height: 6),
          const SkeletonLoading(height: 14, width: 200),
        ],
      ),
    );
  }
}

class OrderSkeleton extends StatelessWidget {
  const OrderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoading(height: 16, width: 120),
              SkeletonLoading(height: 24, width: 80, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonLoading(height: 14, width: 180),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoading(height: 14, width: 100),
              SkeletonLoading(height: 18, width: 90),
            ],
          ),
        ],
      ),
    );
  }
}
