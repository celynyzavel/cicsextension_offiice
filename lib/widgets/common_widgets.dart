import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ============================================================
// COMMON WIDGETS — small reusable pieces used across more than
// one screen. If a helper is only ever used inside a single
// screen, keep it in that screen's file instead of here.
// ============================================================

Widget cardBox({required Widget child, EdgeInsets? margin}) {
  return Container(
    margin: margin ?? const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kCardBorder),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    ),
    child: child,
  );
}

void showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: kPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Text(msg, style: const TextStyle(color: kWhite)),
    ),
  );
}
