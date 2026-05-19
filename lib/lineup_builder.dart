/// A reusable Flutter package for rendering football/soccer lineup formations.
///
/// This library provides widgets for displaying team lineups on a pitch,
/// supporting both read-only display mode and interactive builder mode with
/// drag-and-drop repositioning.
///
/// ## Features
///
/// - Render one or two teams on a pitch with automatic formation-based positioning
/// - Drag-and-drop player repositioning (builder mode)
/// - Haptic feedback and visual cues during drag interactions
/// - Customizable pitch colors, dimensions, and player node rendering
/// - Formation parsing (e.g. "4-3-3", "4-2-3-1")
/// - Player stat badges (rating, goals, assists, cards, substitutions)
///
/// ## Quick Start
///
/// ```dart
/// import 'package:lineup_builder/lineup_builder.dart';
///
/// // Display mode (read-only, two teams):
/// LineupPitch(
///   homeTeam: LineupTeam(name: 'Arsenal', formation: '4-3-3', players: [...]),
///   awayTeam: LineupTeam(name: 'Chelsea', formation: '4-2-3-1', players: [...]),
/// )
///
/// // Builder mode (draggable, single team):
/// DraggableLineupPitch(
///   team: myTeam,
///   onPositionsChanged: (positions) { /* save positions */ },
/// )
/// ```
///
/// ## Architecture
///
/// Use [LineupPlayer]
/// and [LineupTeam] as the data interface. Map your domain entities to these
/// models before passing them to the widgets.
library;

// Models
export 'src/models/lineup_config.dart';
export 'src/models/lineup_player.dart';

// Main Widget
export 'src/lineup_builder_widget.dart';

// Widgets (lower-level, for advanced usage)
export 'src/widgets/draggable_lineup_pitch.dart';
export 'src/widgets/lineup_pitch.dart';
export 'src/widgets/pitch_painter.dart';
export 'src/widgets/player_node.dart';
export 'src/widgets/tactical_board_pitch.dart';

// Utils
export 'src/utils/formation_layout.dart';
export 'src/utils/formation_parser.dart';
export 'src/utils/rating_color.dart';
