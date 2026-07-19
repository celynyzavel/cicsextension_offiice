import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_role.dart';

class AuthService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<String?> login({
    required UserRole role,
    required String email,
    required String password,
  }) async {
    final query = await _db
        .collection('users')
        .where('role', isEqualTo: role.label)
        .where('email', isEqualTo: email.trim())
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }
}