import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:contact_assistant/core/router.dart';
import 'package:contact_assistant/core/utils/mongodb_service.dart';
import 'package:contact_assistant/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization failed. Please restart the app.'),
        ),
      ),
    ));
    return;
  }

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Failed to load environment variables: $e');
    return;
  }

  // Connect to MongoDB Atlas
  try {
    await MongoDbService().connect();
  } catch (e) {
    debugPrint('MongoDB connection failed: $e');
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to connect. Please check your connection and restart.',
          ),
        ),
      ),
    ));
    return;
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'Personal CRM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
