import 'package:flutter/material.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;
        final bannerHeight = isCompact ? 135.0 : 160.0;
        final fontSize = isCompact ? 18.0 : 25.0;
        final horizontalPadding = isCompact ? 20.0 : 36.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: bannerHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF252A48),
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/banner-bg.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Positioned(
                    left: horizontalPadding,
                    top: 0,
                    bottom: 0,
                    right: isCompact ? 140 : 260,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'KEEP UP WITH YOUR\nBUSINESS NEEDS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w800,
                          height: 1.22,
                          letterSpacing: 0.4,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    right: isCompact ? 12 : 24,
                    top: isCompact ? 6 : 10,
                    bottom: isCompact ? 6 : 10,
                    child: Image.asset(
                      'assets/earth_boxes.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/earth_boxes.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(const Color(0xFFCBD5E1)),
                  const SizedBox(width: 8),
                  _dot(const Color(0xFF252A48)), // active
                  const SizedBox(width: 8),
                  _dot(const Color(0xFFCBD5E1)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dot(Color color) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      );
}

