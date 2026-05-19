# lineup_builder

A reusable Flutter package for rendering football/soccer lineup formations on a pitch. Bring your own data, map it to `LineupPlayer`, and render.

## Features

- **Display mode** — Render match lineups with player stats (rating, goals, assists, cards, substitutions)
- **Builder mode** (planned) — Drag-and-drop lineup builder for custom formations
- **Customizable** — Override pitch colors, sizes, player node rendering
- **Isolated** — No dependency on any app entity/model. Uses its own `LineupPlayer` model.

## Usage

```dart
import 'package:lineup_builder/lineup_builder.dart';

LineupPitch(
  homeTeam: LineupTeam(
    name: 'Arsenal',
    formation: '4-3-3',
    shirtColor: Colors.red,
    players: [
      LineupPlayer(id: 1, name: 'Raya', number: 22, position: 'Goalkeeper', gridPosition: 1),
      LineupPlayer(id: 2, name: 'White', number: 4, position: 'Defender', gridPosition: 31),
      // ... more players
    ],
  ),
  awayTeam: LineupTeam(
    name: 'Chelsea',
    formation: '4-2-3-1',
    shirtColor: Colors.blue,
    players: [...],
  ),
  onPlayerTap: (player) {
    // Navigate to player detail
  },
)
```

## Custom Player Node

Override the default player rendering:

```dart
LineupPitch(
  homeTeam: homeTeam,
  awayTeam: awayTeam,
  playerNodeBuilder: (player, shirtColor) {
    return MyCustomPlayerWidget(player: player);
  },
)
```

## Configuration

```dart
LineupPitch(
  homeTeam: homeTeam,
  awayTeam: awayTeam,
  config: LineupPitchConfig(
    pitchColor: Colors.green.shade900,
    pitchHeight: 600,
    playerAvatarSize: 32,
    borderRadius: 12,
  ),
)
```

## Models

- `LineupPlayer` — Player data (name, number, stats, badges)
- `LineupTeam` — Team data (name, formation, players, shirt color)
- `LineupPitchConfig` — Visual configuration

## Widgets

- `LineupPitch` — Main widget rendering the full pitch with both teams
- `PlayerNode` — Individual player on the pitch (can be used standalone)
- `PitchPainter` — CustomPainter for pitch markings
