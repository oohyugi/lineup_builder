import 'package:lineup_builder/src/models/lineup_player.dart';
import 'package:lineup_builder/src/utils/formation_parser.dart';

/// A normalized (x, y) position on the pitch, where each axis is in [0.0, 1.0].
///
/// - `x = 0.0` is the left edge, `x = 1.0` is the right edge
/// - `y = 0.0` is the top edge, `y = 1.0` is the bottom edge
///
/// Used internally by formation layout calculators.
class NormalizedPoint {
  const NormalizedPoint(this.x, this.y);

  /// Horizontal position (0.0 = left, 1.0 = right).
  final double x;

  /// Vertical position (0.0 = top, 1.0 = bottom).
  final double y;
}

/// Layout boundaries for a team on the pitch.
///
/// Defines the goalkeeper's Y position and the Y range used to spread
/// outfield rows from defense to attack.
class FormationLayoutBounds {
  const FormationLayoutBounds({
    required this.gkY,
    required this.defenseY,
    required this.attackY,
    this.maxRowSpread = 0.85,
    this.maxPlayerSpacing = 0.3,
    this.reverseRowOrder = false,
  });

  /// Y position for the goalkeeper.
  final double gkY;

  /// Y position for the defense row (closest to GK).
  final double defenseY;

  /// Y position for the most forward attacking row.
  final double attackY;

  /// Maximum horizontal spread (fraction of pitch width).
  final double maxRowSpread;

  /// Maximum spacing between players in the same row.
  final double maxPlayerSpacing;

  /// When `true`, reverses the player order within each row.
  /// Used for the bottom-half team in two-team mode to keep wingers
  /// on the correct sides.
  final bool reverseRowOrder;

  /// Predefined bounds for a team in the top half of a two-team pitch.
  static const topHalf = FormationLayoutBounds(
    gkY: 0.07,
    defenseY: 0.18,
    attackY: 0.45,
  );

  /// Predefined bounds for a team in the bottom half of a two-team pitch.
  static const bottomHalf = FormationLayoutBounds(
    gkY: 0.93,
    defenseY: 0.82,
    attackY: 0.55,
    reverseRowOrder: true,
  );

  /// Predefined bounds for a team using the full pitch (single-team mode).
  ///
  /// GK at the bottom, defenders close to it, forwards near the top.
  static const fullPitch = FormationLayoutBounds(
    gkY: 0.92,
    defenseY: 0.78,
    attackY: 0.10,
    maxRowSpread: 0.80,
    maxPlayerSpacing: 0.28,
  );
}

/// A player together with its normalized position on the pitch.
class PositionedPlayer {
  const PositionedPlayer(this.player, this.position);

  final LineupPlayer player;
  final NormalizedPoint position;
}

/// Splits the goalkeeper from the outfield players.
///
/// The goalkeeper is identified by having
/// [PlayerPosition.goalkeeper] as their position.
///
/// Returns `(goalkeeper, outfieldPlayers)`. The goalkeeper may be `null`
/// if no player has the goalkeeper position.
({LineupPlayer? gk, List<LineupPlayer> outfield}) splitGoalkeeper(
  List<LineupPlayer> players,
) {
  if (players.isEmpty) {
    return (gk: null, outfield: const []);
  }

  final candidate = players.first;
  if (candidate.position == PlayerPosition.goalkeeper) {
    return (gk: candidate, outfield: players.sublist(1));
  }
  return (gk: null, outfield: players);
}

/// Calculates normalized positions for a team's players based on a formation
/// string and layout bounds.
///
/// Used by both [LineupPitch] and [DraggableLineupPitch] to compute the
/// initial layout. Returns one [PositionedPlayer] per player in the team,
/// in the same order as the input.
///
/// ## Example
///
/// ```dart
/// final positioned = calculateFormationLayout(
///   players: team.players,
///   formation: '4-3-3',
///   bounds: FormationLayoutBounds.fullPitch,
/// );
/// ```
List<PositionedPlayer> calculateFormationLayout({
  required List<LineupPlayer> players,
  required String formation,
  required FormationLayoutBounds bounds,
}) {
  if (players.isEmpty) return const [];

  final split = splitGoalkeeper(players);
  final formationRows = parseFormation(formation);

  final result = <PositionedPlayer>[];

  // Place goalkeeper
  if (split.gk != null) {
    result.add(
      PositionedPlayer(split.gk!, NormalizedPoint(0.5, bounds.gkY)),
    );
  }

  // Distribute outfield players across formation rows
  final outfield = split.outfield;
  final rowCount = formationRows.length;
  final stepY =
      rowCount > 1 ? (bounds.attackY - bounds.defenseY) / (rowCount - 1) : 0.0;

  int playerIndex = 0;

  for (int rowIdx = 0; rowIdx < rowCount; rowIdx++) {
    int rowSize = formationRows[rowIdx];
    if (playerIndex + rowSize > outfield.length) {
      rowSize = outfield.length - playerIndex;
    }
    if (rowSize <= 0) break;

    final rowPlayers = outfield.sublist(playerIndex, playerIndex + rowSize);
    final orderedRow =
        bounds.reverseRowOrder ? rowPlayers.reversed.toList() : rowPlayers;

    final y = bounds.defenseY + (stepY * rowIdx);
    final spacing = orderedRow.length > 1
        ? (bounds.maxRowSpread / (orderedRow.length - 1))
            .clamp(0.0, bounds.maxPlayerSpacing)
        : 0.0;

    for (int colIdx = 0; colIdx < orderedRow.length; colIdx++) {
      final x = 0.5 + (colIdx - (orderedRow.length - 1) / 2) * spacing;
      result.add(
        PositionedPlayer(orderedRow[colIdx], NormalizedPoint(x, y)),
      );
    }

    playerIndex += rowSize;
  }

  return result;
}
