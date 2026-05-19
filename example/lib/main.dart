import 'package:flutter/material.dart';
import 'package:lineup_builder_example/pages/builder_mode_page.dart';
import 'package:lineup_builder_example/pages/display_mode_page.dart';
import 'package:lineup_builder_example/pages/tactical_mode_page.dart';

void main() {
  runApp(const LineupBuilderExampleApp());
}

class LineupBuilderExampleApp extends StatelessWidget {
  const LineupBuilderExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lineup Builder Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lineup Builder')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExampleCard(
            title: 'Display Mode',
            subtitle: 'View a match lineup with player stats',
            icon: Icons.sports_soccer,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DisplayModePage()),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleCard(
            title: 'Builder Mode',
            subtitle: 'Drag players to build a custom lineup',
            icon: Icons.edit_note_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BuilderModePage()),
            ),
          ),
          const SizedBox(height: 12),
          _ExampleCard(
            title: 'Tactical Board',
            subtitle: 'Two-team drag-and-drop for tactical analysis',
            icon: Icons.analytics_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TacticalModePage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
