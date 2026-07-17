import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Technology Transfer ----------------

  static Future<void> addTechnologyTransfer(Map<String, dynamic> data) {
    return _db.collection('technology_transfers').add(data);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamTechnologyTransfers() {
    return _db
        .collection('technology_transfers')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> deleteTechnologyTransfer(String docId) {
    return _db.collection('technology_transfers').doc(docId).delete();
  }
}

