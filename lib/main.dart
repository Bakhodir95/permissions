import 'package:flutter/material.dart';
import 'package:lesson72/firebase_options.dart';
import 'package:lesson72/services/firestore_firebase_service.dart';
import 'package:lesson72/services/location_service.dart';
import 'package:lesson72/views/screens/home_screen_map.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocationService.init();
  await LocationService.getCurrentLocation();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => FirestoreFirebaseService(),
        builder: (context, child) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: HomeScreenMap(),
          );
        });
  }
}
