import 'package:flutter/material.dart';

// ─── Core shimmer widget ──────────────────────────────────────────────────────

/// A single shimmer block. Wrap any shape with it.
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFF1F5F9), _anim.value)!,
              Color.lerp(const Color(0xFFF1F5F9), const Color(0xFFE2E8F0), _anim.value)!,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Composites ───────────────────────────────────────────────────────────────

/// Skeleton for the big balance card (left overview card)
class SkeletonBalanceCard extends StatelessWidget {
  const SkeletonBalanceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 110, height: 13),
          const SizedBox(height: 10),
          const SkeletonBox(width: 180, height: 28),
          const SizedBox(height: 20),
          const SkeletonBox(width: double.infinity, height: 36, borderRadius: 8),
        ],
      ),
    );
  }
}

/// Skeleton for a small stat metric card (Total Shipments / Exports / Imports)
class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkeletonBox(width: 80, height: 12),
              const SkeletonBox(width: 32, height: 32, borderRadius: 50),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonBox(width: 52, height: 26),
          const SizedBox(height: 8),
          const SkeletonBox(width: 90, height: 11),
        ],
      ),
    );
  }
}

/// Skeleton row for the overview grid (balance card + 3 stat cards)
class SkeletonOverviewGrid extends StatelessWidget {
  final bool isDesktop;
  const SkeletonOverviewGrid({Key? key, required this.isDesktop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 22, child: SkeletonBalanceCard()),
          const SizedBox(width: 14),
          const Expanded(flex: 10, child: SkeletonStatCard()),
          const SizedBox(width: 14),
          const Expanded(flex: 10, child: SkeletonStatCard()),
          const SizedBox(width: 14),
          const Expanded(flex: 10, child: SkeletonStatCard()),
        ],
      );
    }
    return Column(
      children: const [
        SkeletonBalanceCard(),
        SizedBox(height: 14),
        SkeletonStatCard(),
        SizedBox(height: 14),
        SkeletonStatCard(),
        SizedBox(height: 14),
        SkeletonStatCard(),
      ],
    );
  }
}

/// Skeleton for the growth chart area
class SkeletonGrowthChart extends StatelessWidget {
  const SkeletonGrowthChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkeletonBox(width: 120, height: 14),
              Row(
                children: const [
                  SkeletonBox(width: 50, height: 28, borderRadius: 6),
                  SizedBox(width: 8),
                  SkeletonBox(width: 50, height: 28, borderRadius: 6),
                  SizedBox(width: 8),
                  SkeletonBox(width: 50, height: 28, borderRadius: 6),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Fake bars
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (i) {
                final heights = [40.0, 60.0, 50.0, 80.0, 55.0, 100.0, 45.0, 120.0, 90.0, 140.0, 30.0, 160.0];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: SkeletonBox(
                      width: double.infinity,
                      height: heights[i],
                      borderRadius: 4,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for a single shipment list item
class SkeletonShipmentItem extends StatelessWidget {
  const SkeletonShipmentItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 40, height: 40, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 130, height: 13),
                SizedBox(height: 6),
                SkeletonBox(width: 80, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SkeletonBox(width: 60, height: 24, borderRadius: 6),
          const SizedBox(width: 12),
          const SkeletonBox(width: 70, height: 30, borderRadius: 7),
        ],
      ),
    );
  }
}

/// A column of N skeleton shipment rows
class SkeletonShipmentList extends StatelessWidget {
  final int count;
  const SkeletonShipmentList({Key? key, this.count = 4}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const SkeletonShipmentItem()),
    );
  }
}
