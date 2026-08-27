import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gym_tracker/providers/workout_provider.dart';
import 'package:gym_tracker/screens/home_screen.dart';

void main() {
  testWidgets('Home screen shows nav destinations', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => WorkoutProvider(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
  });
}
