import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GymTrackerApp());
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider()..load(),
      child: MaterialApp(
        title: 'Gym Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD8C9A3),
            brightness: Brightness.light,
          ).copyWith(
            primary: const Color(0xFFD8C9A3),
            onPrimary: const Color(0xFF3B2F1E),
            secondary: const Color(0xFF6F4E37),
            onSecondary: Colors.white,
            tertiary: const Color(0xFF5C6B4B),
            onTertiary: Colors.white,
          ),
          useMaterial3: true,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6F4E37),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(color: Color(0xFF6F4E37)),
            floatingLabelStyle: const TextStyle(color: Color(0xFF6F4E37)),
            hintStyle: const TextStyle(color: Color(0xFF8A7963)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8A7963)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6F4E37), width: 2),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
