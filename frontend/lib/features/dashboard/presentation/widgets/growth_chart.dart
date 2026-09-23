import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/dashboard_model.dart';

class GrowthChart extends StatefulWidget {
  final List<GrowthPoint> points;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const GrowthChart({
    Key? key,
    required this.points,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  }) : super(key: key);

  @override
  State<GrowthChart> createState() => _GrowthChartState();
}

class _GrowthChartState extends State<GrowthChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with period buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Company Growth',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildPeriodBtn('Year'),
                    _buildPeriodBtn('Month'),
                    _buildPeriodBtn('Week'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Custom spline chart with axis
          SizedBox(
            height: 220,
            child: widget.points.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        size: Size(constraints.maxWidth, 220),
                        painter: _SplineChartPainter(
                          points: widget.points,
                          primaryColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodBtn(String label) {
    final isSelected = widget.selectedPeriod.toLowerCase() == label.toLowerCase();
    return InkWell(
      onTap: () => widget.onPeriodChanged(label.toLowerCase()),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SplineChartPainter extends CustomPainter {
  final List<GrowthPoint> points;
  final Color primaryColor;

  _SplineChartPainter({
    required this.points,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPadding = 45;
    const double bottomPadding = 25;
    final double chartWidth = size.width - leftPadding;
    final double chartHeight = size.height - bottomPadding;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final textStyle = const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 11,
      fontWeight: FontWeight.w400,
    );

    // Draw horizontal grid lines and Y-axis labels: 0, 200, 400, 600, 800, 1000
    final List<int> yLevels = [0, 200, 400, 600, 800, 1000];
    for (int level in yLevels) {
      final double y = chartHeight - (level / 1000.0) * chartHeight;
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);

      final textSpan = TextSpan(
        text: level == 1000 ? '1,000' : level.toString(),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    if (points.length < 2) return;

    // Calculate (x, y) coordinates
    final List<Offset> offsets = [];
    final double stepX = chartWidth / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final double x = leftPadding + i * stepX;
      final double normalizedValue = (points[i].value / 1000.0).clamp(0.0, 1.0);
      final double y = chartHeight - normalizedValue * chartHeight;
      offsets.add(Offset(x, y));

      // Draw X axis label
      final textSpan = TextSpan(text: points[i].label, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartHeight + 8),
      );
    }

    // Build smooth cubic bezier path
    final path = Path();
    path.moveTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = i > 0 ? offsets[i - 1] : offsets[i];
      final p1 = offsets[i];
      final p2 = offsets[i + 1];
      final p3 = i < offsets.length - 2 ? offsets[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6;

      final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // Fill area below the curve
    final fillPath = Path.from(path)
      ..lineTo(offsets.last.dx, chartHeight)
      ..lineTo(offsets.first.dx, chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withOpacity(0.18),
          primaryColor.withOpacity(0.01),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(leftPadding, 0, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke path
    final strokePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) => true;
}
