import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firestore_services.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await FirestoreService.loadAllRecordsIntoStorage();
  } catch (e) {
    debugPrint('Failed to load records from Firestore: $e');
  }

  runApp(const CicsExtensionApp());
}