import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rental_webapp/firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform.copyWith(
      storageBucket: 'rentalapp001-6da48.firebasestorage.app',
    ),
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
