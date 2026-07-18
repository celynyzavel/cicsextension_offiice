import 'package:flutter/material.dart';
import '../theme/app_colors.dart';


Widget cardBox({required Widget child, EdgeInsets? margin}) {
  return Container(
    margin: margin ?? const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kCardBorder),
    ),
    child: child,
  );
}

void showSnack(BuildContext context, String msg, {bool success = false}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.info_outline,
            color: kWhite,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ],
      ),
    ),
  );
}


class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  const SectionLabel(this.text, {super.key, this.padding = const EdgeInsets.only(bottom: 10, top: 4)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(width: 3, height: 13, decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: kTextSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  const StatusChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) return const SizedBox.shrink();
    final c = statusColorFor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: c.fg, fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}


class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBadge({super.key, required this.icon, this.color = kPrimary, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}


class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const EmptyState({super.key, this.icon = Icons.inbox_outlined, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: kSurfaceAlt, shape: BoxShape.circle),
              child: Icon(icon, color: kMuted, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextSecondary, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
class BrandHeaderBanner extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const BrandHeaderBanner({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 32, 24, 36),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        gradient: kBrandGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: child,
    );
  }
}
