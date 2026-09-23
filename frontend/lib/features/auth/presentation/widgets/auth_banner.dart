import 'package:flutter/material.dart';
import '../../../../shared/widgets/dotted_world_map.dart';

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
    return DottedWorldMapBackground(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
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
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
