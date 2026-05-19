import 'package:flutter/material.dart';
import 'package:lineup_builder/lineup_builder.dart';
import 'package:lineup_builder_example/data/sample_data.dart';

/// Demonstrates LineupBuilder.display — read-only two-team match lineup.
class DisplayModePage extends StatelessWidget {
  const DisplayModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display Mode')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _TeamHeader(team: arsenalTeam, isHome: true),

            // ✅ Using LineupBuilder.display
            LineupBuilder.display(
              homeTeam: arsenalTeam,
              awayTeam: chelseaTeam,
              onPlayerTap: (player) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${player.name} (#${player.number})'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),

            _TeamHeader(team: chelseaTeam, isHome: false),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.team, required this.isHome});
  final LineupTeam team;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: team.shirtColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              team.name.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  team.formation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isHome ? 'HOME' : 'AWAY',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
