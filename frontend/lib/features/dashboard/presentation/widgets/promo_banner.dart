import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/app_icons.dart';

/// Matches CSS: .promo-banner
/// background: linear-gradient(overlay) + banner-bg.png + earth-boxes.svg
class PromoBanner extends StatelessWidget {
  const PromoBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Banner ──────────────────────────────────────────────────────
        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // Dark overlay on top of the banner-bg texture
            image: const DecorationImage(
              image: AssetImage('assets/banner-bg.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color(0xD9262A48), // rgba(38,42,72,0.85)
                BlendMode.srcOver,
              ),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // Fallback gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B2240), Color(0xFF222C4A)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // Illustration on the right (matches CSS .globe-icon-circle)
              Positioned(
                right: 44,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: AppIcons.globeCircle(size: 42),
                    ),
                  ),
                ),
              ),

              // Text on the left (matches CSS: padding 0 44px 28px, align flex-end)
              Positioned(
                left: 44,
                bottom: 28,
                right: 220,
                child: const Text(
                  'KEEP UP WITH YOUR\nBUSINESS NEEDS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Carousel dots ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(const Color(0xFFCBD5E1)),
              const SizedBox(width: 6),
              _dot(const Color(0xFF1E243A)), // active
              const SizedBox(width: 6),
              _dot(const Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dot(Color color) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
