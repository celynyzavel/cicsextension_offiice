import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const List<Color> chartPalette = [
  kPrimary,
  kGold,
  Color(0xFF2F9E44),
  Color(0xFF6741D9),
  Color(0xFF0C8599),
  kDanger,
];

class EmptyChartState extends StatelessWidget {
  final String message;
  const EmptyChartState({super.key, this.message = "No data yet."});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.query_stats, color: kMuted, size: 22),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: kTextSecondary, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleBarChart extends StatelessWidget {
  final Map<String, int> data;
  final Color barColor;

  const SimpleBarChart({
    super.key,
    required this.data,
    this.barColor = kPrimary,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const EmptyChartState();
    }

    final maxVal = data.values.fold<int>(0, (p, v) => v > p ? v : p);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((e) {
        final ratio = maxVal == 0 ? 0.0 : e.value / maxVal;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                child: Text(
                  e.key,
                  style: const TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: kSurfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio == 0 ? 0.02 : ratio.clamp(0.02, 1.0),
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [barColor.withValues(alpha: 0.75), barColor],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 30,
                child: Text(
                  '${e.value}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: kTextPrimary, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class SimplePieChart extends StatelessWidget {
  final Map<String, int> data;

  const SimplePieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (p, v) => p + v);

    if (total == 0) {
      return const EmptyChartState();
    }

    final entries = data.entries.toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 112,
          height: 112,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(112, 112),
                painter: _PiePainter(entries: entries, total: total),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const Text('total', style: TextStyle(color: kTextSecondary, fontSize: 10.5)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < entries.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: chartPalette[i % chartPalette.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          entries[i].key,
                          style: const TextStyle(color: kTextPrimary, fontSize: 12.5, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${entries[i].value}',
                        style: const TextStyle(color: kTextSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;
  final int total;

  _PiePainter({required this.entries, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.22;
    final inset = strokeWidth / 2;
    final arcRect = Rect.fromLTWH(inset, inset, size.width - strokeWidth, size.height - strokeWidth);
    double startAngle = -pi / 2;

    for (int i = 0; i < entries.length; i++) {
      final sweep = (entries[i].value / total) * 2 * pi;
      final paint = Paint()
        ..color = chartPalette[i % chartPalette.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(arcRect, startAngle, sweep - 0.02, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.entries != entries || oldDelegate.total != total;
  }
}
