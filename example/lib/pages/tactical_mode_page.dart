import 'package:flutter/material.dart';
import 'package:lineup_builder/lineup_builder.dart';
import 'package:lineup_builder_example/data/tactical_data.dart';

/// Demonstrates LineupBuilder.tactical — two-team drag-and-drop tactical board.
///
/// Both teams are on the full pitch. Any player can be dragged anywhere,
/// including into the opponent's half, to visualize pressing, transitions,
/// and formation matchups.
class TacticalModePage extends StatefulWidget {
  const TacticalModePage({super.key});

  @override
  State<TacticalModePage> createState() => _TacticalModePageState();
}

class _TacticalModePageState extends State<TacticalModePage> {
  String _homeFormation = '4-3-3';
  String _awayFormation = '4-2-3-1';
  TacticalPositions? _lastPositions;

  static const _formations = [
    '4-3-3',
    '4-4-2',
    '4-2-3-1',
    '3-5-2',
    '3-4-3',
    '5-3-2',
    '4-1-4-1',
  ];

  LineupTeam get _homeTeam =>
      tacticalHomeTeam.copyWith(formation: _homeFormation);
  LineupTeam get _awayTeam =>
      tacticalAwayTeam.copyWith(formation: _awayFormation);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tactical Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset positions',
            onPressed: () => setState(() => _lastPositions = null),
          ),
        ],
      ),
      body: Column(
        children: [
          // Formation selectors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Home team
                Expanded(
                  child: _FormationSelector(
                    label: tacticalHomeTeam.name,
                    color: tacticalHomeTeam.shirtColor ?? Colors.red,
                    value: _homeFormation,
                    formations: _formations,
                    onChanged: (f) => setState(() => _homeFormation = f),
                  ),
                ),
                const SizedBox(width: 8),
                Text('vs', style: theme.textTheme.titleSmall),
                const SizedBox(width: 8),
                // Away team
                Expanded(
                  child: _FormationSelector(
                    label: tacticalAwayTeam.name,
                    color: tacticalAwayTeam.shirtColor ?? Colors.blue,
                    value: _awayFormation,
                    formations: _formations,
                    onChanged: (f) => setState(() => _awayFormation = f),
                  ),
                ),
              ],
            ),
          ),

          // Hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Drag any player anywhere • Tap to see details',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ✅ Tactical board — uses LayoutBuilder to fill available space
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return LineupBuilder.tactical(
                  homeTeam: _homeTeam,
                  awayTeam: _awayTeam,
                  config: LineupPitchConfig(
                    pitchHeight: constraints.maxHeight,
                    playerAvatarSize: 28,
                    horizontalPadding: 8,
                    verticalPadding: 4,
                  ),
                  haptic: const HapticConfig(type: HapticType.light),
                  onTacticalPlayerTap: (ref) {
                    _showPlayerSheet(context, ref);
                  },
                  onTacticalPositionsChanged: (positions) {
                    setState(() => _lastPositions = positions);
                  },
                );
              },
            ),
          ),

          // Status bar
          if (_lastPositions != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.surfaceContainerHigh,
              child: Row(
                children: [
                  Icon(
                    Icons.edit_location_alt_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_lastPositions!.homePositions.length} home · '
                    '${_lastPositions!.awayPositions.length} away repositioned',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showPlayerSheet(BuildContext context, TacticalPlayerRef ref) {
    final isHome = ref.side == TacticalTeamSide.home;
    final teamName = isHome ? tacticalHomeTeam.name : tacticalAwayTeam.name;
    final teamColor = isHome
        ? (tacticalHomeTeam.shirtColor ?? Colors.red)
        : (tacticalAwayTeam.shirtColor ?? Colors.blue);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: teamColor,
              child: Text(
                ref.player.number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.player.name ?? '#${ref.player.number}',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$teamName · ${ref.player.position}',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormationSelector extends StatelessWidget {
  const _FormationSelector({
    required this.label,
    required this.color,
    required this.value,
    required this.formations,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final String value;
  final List<String> formations;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: formations
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (f) {
              if (f != null) onChanged(f);
            },
          ),
        ),
      ],
    );
  }
}
