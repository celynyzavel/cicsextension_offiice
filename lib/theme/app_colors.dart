import 'package:flutter/material.dart';

// Surfaces
const kBackground = Color(0xFFF3F5F9);
const kSurfaceAlt = Color(0xFFEDF0F7);
const kSidebar = Color(0xFF101A38);
const kSidebarAlt = Color(0xFF1B2A54);

const kCard = Colors.white;
const kCardBorder = Color(0xFFE4E8F1);

const kInfo = Color(0xFFEAF0FD);

// Brand / primary
const kPrimary = Color(0xFF153059);
const kPrimaryHover = Color(0xFF1B3599);
const kPrimaryLight = Color(0xFF5C7CF0);

const kWhite = Colors.white;

// Text
const kTextPrimary = Color(0xFF161D34);
const kTextSecondary = Color.fromARGB(255, 93, 100, 117);
const kMuted = Color(0xFFD1D5DB);

// Accent / secondary brand
const kGold = Color(0xFFA97417);
const kGoldLight = Color(0xFFF4E4C6);

// Semantic status colors
const kSuccess = Color(0xFF15803D);
const kSuccessBg = Color(0xFFE5F6EA);
const kWarning = Color(0xFFB45309);
const kWarningBg = Color(0xFFFCF0DD);
const kDanger = Color(0xFFC0392B);
const kDangerBg = Color(0xFFFBE9E7);
const kOrange = kDanger; 

const kNeutralBg = Color(0xFFEEF0F5);

const kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kSidebar, kPrimary],
);


List<BoxShadow> get kCardShadow => [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ];


({Color fg, Color bg}) statusColorFor(String status) {
  final s = status.toLowerCase();
  if (s.contains('complete') || s.contains('active') || s.contains('done') || s.contains('approved')) {
    return (fg: kSuccess, bg: kSuccessBg);
  }
  if (s.contains('pending') || s.contains('progress') || s.contains('review') || s.contains('ongoing')) {
    return (fg: kWarning, bg: kWarningBg);
  }
  if (s.contains('cancel') || s.contains('inactive') || s.contains('discontinu') || s.contains('reject')) {
    return (fg: kDanger, bg: kDangerBg);
  }
  return (fg: kPrimary, bg: kInfo);
}
