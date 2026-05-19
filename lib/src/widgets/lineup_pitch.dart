import 'package:flutter/material.dart';
import 'package:lineup_builder/src/models/lineup_config.dart';
import 'package:lineup_builder/src/models/lineup_player.dart';
import 'package:lineup_builder/src/utils/formation_layout.dart';
import 'package:lineup_builder/src/widgets/pitch_painter.dart';
import 'package:lineup_builder/src/widgets/player_node.dart';

/// A read-only widget that renders a football pitch with one or two teams
/// positioned according to their formations.
///
/// Supports two display modes:
///
/// - **Two-team mode** (default): Home team in the top half, away team in
///   the bottom half. Both teams are rendered with their respective
///   formations.
/// - **Single-team mode**: The home team occupies the full pitch height
///   with the goalkeeper at the bottom and forwards at the top. Activated
///   automatically when [awayTeam] is null or has an empty players list,
///   or when [LineupPitchConfig.singleTeamMode] is set to `true`.
///
/// ## Two-Team Example
///
/// ```dart
/// LineupPitch(
///   homeTeam: LineupTeam(name: 'Arsenal', formation: '4-3-3', players: [...]),
///   awayTeam: LineupTeam(name: 'Chelsea', formation: '4-2-3-1', players: [...]),
///   onPlayerTap: (player) => showPlayerSheet(player),
/// )
/// ```
///
/// ## Single-Team Example (awayTeam omitted)
///
/// ```dart
/// LineupPitch(
///   homeTeam: LineupTeam(name: 'Arsenal', formation: '4-3-3', players: [...]),
///   config: LineupPitchConfig(pitchHeight: 600),
/// )
/// ```
///
/// ## Custom Player Nodes
///
/// Use [playerNodeBuilder] to replace the default [PlayerNode] widget
/// with a custom implementation:
///
/// ```dart
/// LineupPitch(
///   homeTeam: myTeam,
///   playerNodeBuilder: (player, shirtColor) => MyCustomNode(player),
/// )
/// ```
///
/// For interactive drag-and-drop positioning, use [DraggableLineupPitch].
class LineupPitch extends StatelessWidget {
  /// Creates a lineup pitch widget.
  ///
  /// The [homeTeam] is required and always rendered. The [awayTeam] is
  /// optional — when null or when its players list is empty, the widget
  /// automatically switches to single-team mode.
  const LineupPitch({
    super.key,
    required this.homeTeam,
    this.awayTeam,
    this.config = const LineupPitchConfig(),
    this.onPlayerTap,
    this.playerNodeBuilder,
  });

  /// Home team data (displayed at the top half in two-team mode, or full
  /// pitch in single-team mode).
  final LineupTeam homeTeam;

  /// Away team data (displayed at the bottom half).
  ///
  /// When null or when [LineupTeam.players] is empty, the widget
  /// automatically uses single-team mode for the [homeTeam], regardless
  /// of the [LineupPitchConfig.singleTeamMode] setting.
  final LineupTeam? awayTeam;

  /// Visual and behavioral configuration for the pitch.
  ///
  /// Controls colors, dimensions, border radius, and display mode.
  /// See [LineupPitchConfig] for all available options.
  final LineupPitchConfig config;

  /// Callback invoked when a player node is tapped.
  ///
  /// Receives the tapped [LineupPlayer] instance. Useful for showing
  /// player detail sheets or navigating to player profiles.
  final void Function(LineupPlayer player)? onPlayerTap;

  /// Optional custom builder for player nodes.
  ///
  /// When provided, replaces the default [PlayerNode] widget for every
  /// player on the pitch. Receives the [LineupPlayer] data and the team's
  /// shirt color.
  final Widget Function(LineupPlayer player, Color? shirtColor)?
      playerNodeBuilder;

  /// Whether single-team mode applies based on config or away team state.
  bool get _useSingleTeamMode =>
      config.singleTeamMode || awayTeam == null || awayTeam!.players.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: config.pitchHeight,
      margin: EdgeInsets.symmetric(
        horizontal: config.horizontalPadding,
        vertical: config.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: config.pitchColor,
        borderRadius: BorderRadius.circular(config.borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: PitchPainter(color: config.lineColor),
            ),
          ),
          ..._buildPlayerWidgets(),
        ],
      ),
    );
  }

  /// Builds all positioned player widgets for the current mode.
  List<Widget> _buildPlayerWidgets() {
    if (_useSingleTeamMode) {
      return _layoutTeam(homeTeam, FormationLayoutBounds.fullPitch);
    }

    return [
      ..._layoutTeam(homeTeam, FormationLayoutBounds.topHalf),
      ..._layoutTeam(awayTeam!, FormationLayoutBounds.bottomHalf),
    ];
  }

  /// Computes positions for a team and wraps each player in an [Align].
  List<Widget> _layoutTeam(LineupTeam team, FormationLayoutBounds bounds) {
    final positioned = calculateFormationLayout(
      players: team.players,
      formation: team.formation,
      bounds: bounds,
    );

    return positioned
        .map((pp) => _alignedPlayer(pp, team.shirtColor))
        .toList(growable: false);
  }

  /// Wraps a positioned player in an [Align] using normalized coordinates.
  Widget _alignedPlayer(PositionedPlayer pp, Color? shirtColor) {
    final node = playerNodeBuilder != null
        ? playerNodeBuilder!(pp.player, shirtColor)
        : PlayerNode(
            player: pp.player,
            shirtColor: shirtColor,
            avatarSize: config.playerAvatarSize,
            onTap: onPlayerTap != null ? () => onPlayerTap!(pp.player) : null,
          );

    return Align(
      alignment: Alignment(
        (pp.position.x - 0.5) * 2,
        (pp.position.y - 0.5) * 2,
      ),
      child: node,
    );
  }
}
