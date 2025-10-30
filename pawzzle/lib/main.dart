import 'package:flutter/material.dart';
import 'screens/main_menu_screen.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vexsfgtialxsbftneecj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZleHNmZ3RpYWx4c2JmdG5lZWNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MzUyNTksImV4cCI6MjA3NzQxMTI1OX0.al6xNQUiS3kWm8x2u7E0aB3d-hZNPHAulW7ee1l0_mA',
  );
  final supabase = Supabase.instance.client;

  // Проверяем есть ли пользователь, если нет — создаём анонимного
  // if (supabase.auth.currentUser == null) {
  //   await supabase.auth.signInAnonymously();
  // }

  runApp(const PawzzleApp());
}

class PawzzleApp extends StatelessWidget {
  const PawzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
