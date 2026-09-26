import 'package:flutter/material.dart';
import '../../../../shared/widgets/dotted_world_map.dart';

/// Replicates CSS: .auth-banner-side, .auth-banner-canvas, .auth-banner-title, .auth-banner-desc
class AuthBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthBanner({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF5A65AB), // var(--primary)
      child: Stack(
        children: [
          // Dotted World Map canvas covering entire banner
          Positioned.fill(
            child: CustomPaint(
              painter: DottedWorldMapPainter(
                dotColor: Colors.white,
              ),
            ),
          ),

          // Content aligned to bottom: padding: 64px 56px
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(56, 32, 56, 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
