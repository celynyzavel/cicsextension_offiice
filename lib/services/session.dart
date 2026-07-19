import '../models/user_role.dart';

class Session {
  static String? currentUserEmail;
  static UserRole? currentUserRole;
  static String? currentUserId;

  static void set({
    required String email,
    required UserRole role,
    required String userId,
  }) {
    currentUserEmail = email.trim();
    currentUserRole = role;
    currentUserId = userId;
  }

  static void clear() {
    currentUserEmail = null;
    currentUserRole = null;
    currentUserId = null;
  }
}
