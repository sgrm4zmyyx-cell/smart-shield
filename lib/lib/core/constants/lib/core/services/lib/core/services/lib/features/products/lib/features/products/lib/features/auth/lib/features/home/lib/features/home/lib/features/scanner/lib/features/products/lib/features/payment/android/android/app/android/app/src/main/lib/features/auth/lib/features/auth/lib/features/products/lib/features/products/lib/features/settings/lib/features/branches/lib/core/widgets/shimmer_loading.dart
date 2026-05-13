import 'package:flutter/material.dart';
import 'package:smart_shield/core/constants/app_colors.dart';

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // ✅ الحل: نحرك الـ Alignment بدل الـ stops
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_controller.value * 2 - 1, 0),
              end: Alignment(_controller.value * 2, 0),
              colors: const [
                Color(0xFFE8EDF2),
                Color(0xFFF8FAFF),
                Color(0xFFE8EDF2),
              ],
              // ✅ stops ثابتة ومتصاعدة دايماً
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const ShimmerLoading(width: 48, height: 48, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(height: 14),
                const SizedBox(height: 8),
                ShimmerLoading(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 12),
                const SizedBox(height: 6),
                ShimmerLoading(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const ShimmerLoading(width: 60, height: 28, borderRadius: 14),
        ],
      ),
    );
  }
}

class ShimmerGridCard extends StatelessWidget {
  const ShimmerGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerLoading(width: 36, height: 36, borderRadius: 8),
          SizedBox(height: 8),
          ShimmerLoading(width: 48, height: 10),
          SizedBox(height: 4),
          ShimmerLoading(width: 36, height: 10),
        ],
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0F4FF),
            Color(0xFFF5F7FA),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: 8,
                itemBuilder: (_, __) => const ShimmerGridCard(),
              ),
              const SizedBox(height: 20),
              const ShimmerCard(),
              const ShimmerCard(),
              const ShimmerCard(),
            ],
          ),
        ),
      ),
    );
  }
}
