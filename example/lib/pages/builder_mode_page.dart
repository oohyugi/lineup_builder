import 'package:flutter/material.dart';
import 'package:lineup_builder/lineup_builder.dart';
import 'package:lineup_builder_example/data/sample_data.dart';

/// Demonstrates LineupBuilder.editable — drag-and-drop lineup builder.
class BuilderModePage extends StatefulWidget {
  const BuilderModePage({super.key});

  @override
  State<BuilderModePage> createState() => _BuilderModePageState();
}

class _BuilderModePageState extends State<BuilderModePage> {
  String _formation = '4-3-3';
  String _displayFormation = '4-3-3';
  final List<LineupPlayer> _selectedPlayers = [];
  final List<LineupPlayer> _availableSquad = List.from(sampleSquad);

  static const _formations = [
    '4-3-3',
    '4-4-2',
    '4-2-3-1',
    '3-5-2',
    '3-4-3',
    '5-3-2',
    '4-1-4-1',
  ];

  int get _requiredCount {
    final rows = parseFormation(_formation);
    return rows.fold(0, (sum, r) => sum + r) + 1;
  }

  @override
  void initState() {
    super.initState();
    _autoFill();
  }

  void _autoFill() {
    _selectedPlayers.clear();
    final needed = _requiredCount;
    final available = List<LineupPlayer>.from(_availableSquad);

    final gk = available.firstWhere(
      (p) => p.position == PlayerPosition.goalkeeper,
      orElse: () => available.first,
    );
    _selectedPlayers.add(gk);
    available.remove(gk);

    for (int i = 1; i < needed && available.isNotEmpty; i++) {
      _selectedPlayers.add(available.removeAt(0));
    }
  }

  void _onFormationChanged(String? formation) {
    if (formation == null) return;
    setState(() {
      _formation = formation;
      _displayFormation = formation;
      _autoFill();
    });
  }

  void _onPlayerTap(LineupPlayer player) {
    _showSwapSheet(player);
  }

  void _onReset() {
    setState(() {
      _displayFormation = _formation;
      _autoFill();
    });
  }

  void _showSwapSheet(LineupPlayer currentPlayer) {
    final bench = _availableSquad
        .where((p) => !_selectedPlayers.any((s) => s.id == p.id))
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => _SwapSheet(
        currentPlayer: currentPlayer,
        benchPlayers: bench,
        onSwap: (newPlayer) {
          setState(() {
            final index =
                _selectedPlayers.indexWhere((p) => p.id == currentPlayer.id);
            if (index != -1) {
              _selectedPlayers[index] = newPlayer;
            }
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  LineupTeam get _builtTeam => LineupTeam(
        name: 'My Team',
        formation: _formation,
        shirtColor: Colors.deepPurple,
        players: _selectedPlayers.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return LineupPlayer(
            id: p.id,
            name: p.name,
            number: p.number,
            position: i == 0 ? PlayerPosition.goalkeeper : p.position,
            isCaptain: i == 0,
          );
        }).toList(),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Builder Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset positions',
            onPressed: _onReset,
          ),
        ],
      ),
      body: Column(
        children: [
          // Formation Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('Formation:', style: theme.textTheme.titleSmall),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _formation,
                  items: _formations
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: _onFormationChanged,
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _displayFormation == 'Free'
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _displayFormation,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _displayFormation == 'Free'
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_selectedPlayers.length}/$_requiredCount',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Drag hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Drag players to reposition • Tap to swap',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ✅ Using LineupBuilder.editable
          Expanded(
            child: LineupBuilder.editable(
              team: _builtTeam,
              config: const LineupPitchConfig(pitchHeight: 500),
              onPlayerTap: _onPlayerTap,
              onFormationChanged: (f) {
                setState(() => _displayFormation = f);
              },
              onPositionsChanged: (positions) {
                // Could save positions to state/backend
                debugPrint('Positions updated: ${positions.length} players');
              },
            ),
          ),

          // Squad List (bottom)
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                  child: Text(
                    'Squad',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _availableSquad.length,
                    itemBuilder: (context, index) {
                      final player = _availableSquad[index];
                      final isSelected =
                          _selectedPlayers.any((p) => p.id == player.id);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _SquadChip(
                          player: player,
                          isSelected: isSelected,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SquadChip extends StatelessWidget {
  const _SquadChip({required this.player, required this.isSelected});
  final LineupPlayer player;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isSelected ? Colors.green : Colors.grey.shade300,
          child: Text(
            player.number.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          player.name ?? '',
          style: TextStyle(
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SwapSheet extends StatelessWidget {
  const _SwapSheet({
    required this.currentPlayer,
    required this.benchPlayers,
    required this.onSwap,
  });
  final LineupPlayer currentPlayer;
  final List<LineupPlayer> benchPlayers;
  final void Function(LineupPlayer) onSwap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Replace ${currentPlayer.name} (#${currentPlayer.number})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (benchPlayers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No available players'),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: benchPlayers.length,
                itemBuilder: (context, index) {
                  final player = benchPlayers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(player.number.toString()),
                    ),
                    title: Text(player.name ?? ''),
                    subtitle: Text(player.position.name),
                    onTap: () => onSwap(player),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
