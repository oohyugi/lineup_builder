import 'package:flutter/material.dart';
import 'package:lineup_builder/src/models/lineup_config.dart';
import 'package:lineup_builder/src/models/lineup_player.dart';
import 'package:lineup_builder/src/widgets/draggable_lineup_pitch.dart';
import 'package:lineup_builder/src/widgets/lineup_pitch.dart';
import 'package:lineup_builder/src/widgets/tactical_board_pitch.dart';

/// The primary entry point for the lineup_builder package.
///
/// Provides four named constructors for different use cases:
///
/// - [LineupBuilder.display] — Read-only two-team match lineup.
/// - [LineupBuilder.single] — Read-only single-team full-pitch view.
/// - [LineupBuilder.editable] — Interactive drag-and-drop lineup builder
///   (single team, full pitch).
/// - [LineupBuilder.tactical] — Two-team tactical board where all players
///   can be dragged anywhere on the pitch.
///
/// ## Display Mode
///
/// ```dart
/// LineupBuilder.display(
///   homeTeam: arsenalTeam,
///   awayTeam: chelseaTeam,
///   onPlayerTap: (player) => showDetails(player),
/// )
/// ```
///
/// ## Single Team Mode
///
/// ```dart
/// LineupBuilder.single(
///   team: arsenalTeam,
/// )
/// ```
///
/// ## Editable Mode (Formation Builder)
///
/// ```dart
/// LineupBuilder.editable(
///   team: myTeam,
///   onPositionsChanged: (positions) => save(positions),
///   onFormationChanged: (f) => updateLabel(f),
/// )
/// ```
///
/// ## Tactical Mode (Two-Team Analysis)
///
/// ```dart
/// LineupBuilder.tactical(
///   homeTeam: arsenalTeam,
///   awayTeam: chelseaTeam,
///   onPositionsChanged: (positions) {
///     // positions.homePositions — home team custom positions
///     // positions.awayPositions — away team custom positions
///   },
///   onPlayerTap: (ref) {
///     // ref.player, ref.side (home/away)
///   },
/// )
/// ```
class LineupBuilder extends StatelessWidget {
  // ── Display ──────────────────────────────────────────────────────────────

  /// Creates a read-only two-team lineup display.
  ///
  /// Both [homeTeam] and [awayTeam] are rendered on their respective halves.
  /// Use this for showing match lineups.
  const LineupBuilder.display({
    super.key,
    required this.homeTeam,
    this.awayTeam,
    this.config,
    this.onPlayerTap,
    this.playerNodeBuilder,
  })  : _mode = _LineupMode.display,
        haptic = const HapticConfig(),
        onPositionsChanged = null,
        onFormationChanged = null,
        onTacticalPlayerTap = null,
        onTacticalPositionsChanged = null,
        tacticalPlayerNodeBuilder = null;

  // ── Single ────────────────────────────────────────────────────────────────

  /// Creates a read-only single-team full-pitch display.
  ///
  /// The team occupies the entire pitch height with the goalkeeper at the
  /// bottom and forwards at the top. Useful for team preview or formation
  /// showcase.
  const LineupBuilder.single({
    super.key,
    required LineupTeam team,
    this.config,
    this.onPlayerTap,
    this.playerNodeBuilder,
  })  : homeTeam = team,
        awayTeam = null,
        _mode = _LineupMode.single,
        haptic = const HapticConfig(),
        onPositionsChanged = null,
        onFormationChanged = null,
        onTacticalPlayerTap = null,
        onTacticalPositionsChanged = null,
        tacticalPlayerNodeBuilder = null;

  // ── Editable ──────────────────────────────────────────────────────────────

  /// Creates an interactive drag-and-drop lineup builder (single team).
  ///
  /// Players can be dragged to any position on the pitch. Once a player is
  /// moved, the formation becomes "Free" and [onFormationChanged] fires.
  ///
  /// Configure haptic feedback via [haptic].
  const LineupBuilder.editable({
    super.key,
    required LineupTeam team,
    this.config,
    this.haptic = const HapticConfig(),
    this.onPlayerTap,
    this.onPositionsChanged,
    this.onFormationChanged,
    this.playerNodeBuilder,
  })  : homeTeam = team,
        awayTeam = null,
        _mode = _LineupMode.editable,
        onTacticalPlayerTap = null,
        onTacticalPositionsChanged = null,
        tacticalPlayerNodeBuilder = null;

  // ── Tactical ──────────────────────────────────────────────────────────────

  /// Creates a two-team tactical board for formation analysis.
  ///
  /// Both teams are displayed on the full pitch and every player can be
  /// dragged anywhere — including into the opponent's half. Designed for
  /// tactical analysts to visualize:
  ///
  /// - Formation matchups
  /// - Pressing shapes and triggers
  /// - Attacking transitions and overloads
  /// - Set-piece positioning
  ///
  /// Use [onTacticalPlayerTap] instead of [onPlayerTap] to receive the
  /// team side alongside the player.
  const LineupBuilder.tactical({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    this.config,
    this.haptic = const HapticConfig(),
    this.onTacticalPlayerTap,
    this.onTacticalPositionsChanged,
    this.tacticalPlayerNodeBuilder,
  })  : _mode = _LineupMode.tactical,
        onPlayerTap = null,
        onPositionsChanged = null,
        onFormationChanged = null,
        playerNodeBuilder = null;

  // ── Fields ────────────────────────────────────────────────────────────────

  final _LineupMode _mode;

  /// Home team (or the only team in single/editable modes).
  final LineupTeam homeTeam;

  /// Away team (display and tactical modes only).
  final LineupTeam? awayTeam;

  /// Visual configuration for the pitch.
  ///
  /// When null, sensible defaults are applied per mode.
  final LineupPitchConfig? config;

  /// Haptic feedback configuration (editable and tactical modes only).
  final HapticConfig haptic;

  // -- Single-team callbacks --

  /// Callback when a player is tapped (display, single, editable modes).
  final void Function(LineupPlayer player)? onPlayerTap;

  /// Called when player positions change after a drag (editable mode).
  final void Function(Map<int, PlayerPosition> positions)? onPositionsChanged;

  /// Called when formation label changes (editable mode).
  ///
  /// Fires with "Free" when a player is dragged, or the original formation
  /// string when positions are reset.
  final void Function(String formation)? onFormationChanged;

  /// Custom player node builder (display, single, editable modes).
  final Widget Function(LineupPlayer player, Color? shirtColor)?
      playerNodeBuilder;

  // -- Tactical callbacks --

  /// Callback when a player is tapped in tactical mode.
  ///
  /// Receives a [TacticalPlayerRef] with the player and their team side.
  final void Function(TacticalPlayerRef ref)? onTacticalPlayerTap;

  /// Called after any drag in tactical mode with positions for both teams.
  final void Function(TacticalPositions positions)? onTacticalPositionsChanged;

  /// Custom player node builder for tactical mode.
  ///
  /// Receives the player, shirt color, and [TacticalTeamSide].
  final Widget Function(
    LineupPlayer player,
    Color? shirtColor,
    TacticalTeamSide side,
  )? tacticalPlayerNodeBuilder;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return switch (_mode) {
      _LineupMode.display => LineupPitch(
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          config: config ?? const LineupPitchConfig(),
          onPlayerTap: onPlayerTap,
          playerNodeBuilder: playerNodeBuilder,
        ),
      _LineupMode.single => LineupPitch(
          homeTeam: homeTeam,
          config: config ?? const LineupPitchConfig(singleTeamMode: true),
          onPlayerTap: onPlayerTap,
          playerNodeBuilder: playerNodeBuilder,
        ),
      _LineupMode.editable => DraggableLineupPitch(
          team: homeTeam,
          config: config ?? const LineupPitchConfig(singleTeamMode: true),
          haptic: haptic,
          onPlayerTap: onPlayerTap,
          onPositionsChanged: onPositionsChanged,
          onFormationChanged: onFormationChanged,
          playerNodeBuilder: playerNodeBuilder,
        ),
      _LineupMode.tactical => TacticalBoardPitch(
          homeTeam: homeTeam,
          awayTeam: awayTeam!,
          config: config ?? const LineupPitchConfig(),
          haptic: haptic,
          onPlayerTap: onTacticalPlayerTap,
          onPositionsChanged: onTacticalPositionsChanged,
          playerNodeBuilder: tacticalPlayerNodeBuilder,
        ),
    };
  }
}

enum _LineupMode { display, single, editable, tactical }
