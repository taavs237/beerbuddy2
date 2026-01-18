import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'models/beer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive (offline DB)
  await Hive.initFlutter();
  Hive.registerAdapter(BeerAdapter());
  await Hive.openBox<Beer>('beers');

  runApp(const BeerBuddyApp());
}
