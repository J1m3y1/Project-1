import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/workout_provider.dart';
import 'achievements_screen.dart';
import 'exercise_selection_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _SessionsTab(),
      const StatsScreen(),
      const AchievementsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_tabIndex]),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton(
              onPressed: () => _startNewSession(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.fitness_center), label: 'Workouts'),
          NavigationDestination(
              icon: Icon(Icons.show_chart), label: 'Progress'),
          NavigationDestination(
              icon: Icon(Icons.emoji_events), label: 'Achievements'),
        ],
      ),
    );
  }

  Future<void> _startNewSession(BuildContext context) async {
    final provider = context.read<WorkoutProvider>();
    final controller = TextEditingController(
      text: 'Workout ${DateFormat.MMMd().format(DateTime.now())}',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New workout'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Workout name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final session = await provider.createSession(name);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseSelectionScreen(session: session),
      ),
    );
  }
}

class _SessionsTab extends StatelessWidget {
  const _SessionsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.sessions.isEmpty) {
          return const Center(
            child: Text('No workouts yet. Tap + to start one.'),
          );
        }
        return ListView.builder(
          itemCount: provider.sessions.length,
          itemBuilder: (context, index) {
            final session = provider.sessions[index];
            return Dismissible(
              key: ValueKey(session.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => provider.deleteSession(session.id),
              child: ListTile(
                leading: const Icon(Icons.event_note),
                title: Text(session.name),
                subtitle: Text(
                  DateFormat.yMMMd().add_jm().format(session.date),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseSelectionScreen(session: session),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
