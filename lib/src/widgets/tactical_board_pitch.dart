import 'package:flutter/material.dart';
import 'package:lineup_builder/src/models/lineup_config.dart';
import 'package:lineup_builder/src/models/lineup_player.dart';
import 'package:lineup_builder/src/utils/drag_constants.dart';
import 'package:lineup_builder/src/utils/formation_layout.dart';
import 'package:lineup_builder/src/widgets/draggable_lineup_pitch.dart';
import 'package:lineup_builder/src/widgets/pitch_painter.dart';
import 'package:lineup_builder/src/widgets/player_node.dart';

/// Identifies which team a player belongs to on the tactical board.
enum TacticalTeamSide { home, away }

/// A player together with its team side, used in tactical callbacks.
class TacticalPlayerRef {
  const TacticalPlayerRef({required this.player, required this.side});

  /// The player data.
  final LineupPlayer player;

  /// Which team this player belongs to.
  final TacticalTeamSide side;
}

/// Positions for both teams on the tactical board.
///
/// Returned by [TacticalBoardPitch.onPositionsChanged] after any drag.
class TacticalPositions {
  const TacticalPositions({
    required this.homePositions,
    required this.awayPositions,
  });

  /// Custom positions for home team players (playerId → position).
  ///
  /// Only contains entries for players that have been manually moved.
  final Map<int, PlayerPosition> homePositions;

  /// Custom positions for away team players (playerId → position).
  ///
  /// Only contains entries for players that have been manually moved.
  final Map<int, PlayerPosition> awayPositions;
}

/// A full-pitch tactical board where both teams can be freely repositioned.
///
/// Designed for **tactical analysis** — coaches and analysts can drag any
/// player from either team to any position on the pitch, including into the
/// opponent's half, to visualize:
///
/// - Formation matchups (e.g. 4-3-3 vs 4-2-3-1)
/// - Pressing triggers and defensive shapes
/// - Attacking transitions and overloads
/// - Set-piece positioning
///
/// ## Key Differences from [DraggableLineupPitch]
///
/// | Feature                  | DraggableLineupPitch | TacticalBoardPitch |
/// |--------------------------|----------------------|--------------------|
/// | Teams                    | 1                    | 2                  |
/// | Drag across halfway line | No                   | Yes                |
/// | Initial layout           | Full pitch           | Half-pitch each    |
/// | Use case                 | Formation builder    | Tactical analysis  |
///
/// ## Example
///
/// ```dart
/// TacticalBoardPitch(
///   homeTeam: arsenalTeam,
///   awayTeam: chelseaTeam,
///   onPositionsChanged: (positions) {
///     // positions.homePositions — home team custom positions
///     // positions.awayPositions — away team custom positions
///   },
///   onPlayerTap: (ref) {
///     // ref.player — the tapped player
///     // ref.side — TacticalTeamSide.home or .away
///   },
/// )
/// ```
///
/// ## Resetting
///
/// Use a [GlobalKey] to call `resetPositions()` on the state:
///
/// ```dart
/// final key = GlobalKey<TacticalBoardPitchState>();
/// key.currentState?.resetPositions();
/// ```
class TacticalBoardPitch extends StatefulWidget {
  /// Creates a tactical board with two draggable teams.
  const TacticalBoardPitch({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    this.config = const LineupPitchConfig(),
    this.haptic = const HapticConfig(),
    this.onPlayerTap,
    this.onPositionsChanged,
    this.playerNodeBuilder,
  });

  /// Home team (initially positioned in the top half).
  final LineupTeam homeTeam;

  /// Away team (initially positioned in the bottom half).
  final LineupTeam awayTeam;

  /// Visual configuration for the pitch.
  final LineupPitchConfig config;

  /// Haptic feedback configuration for drag interactions.
  ///
  /// Defaults to enabled with [HapticType.light].
  final HapticConfig haptic;

  /// Callback when a player is tapped (not dragged).
  ///
  /// Receives a [TacticalPlayerRef] with the player and their team side.
  final void Function(TacticalPlayerRef ref)? onPlayerTap;

  /// Called after any drag completes with the updated positions for both teams.
  final void Function(TacticalPositions positions)? onPositionsChanged;

  /// Optional custom builder for player nodes.
  ///
  /// Receives the player, their shirt color, and which team side they belong to.
  final Widget Function(
    LineupPlayer player,
    Color? shirtColor,
    TacticalTeamSide side,
  )? playerNodeBuilder;

  @override
  State<TacticalBoardPitch> createState() => TacticalBoardPitchState();
}

/// State for [TacticalBoardPitch]. Exposed publicly to allow `resetPositions()`
/// via a [GlobalKey].
class TacticalBoardPitchState extends State<TacticalBoardPitch> {
  /// Custom positions for home team players.
  final Map<int, PlayerPosition> _homePositions = {};

  /// Custom positions for away team players.
  final Map<int, PlayerPosition> _awayPositions = {};

  /// The player currently being dragged, or null.
  ({int id, TacticalTeamSide side})? _dragging;

  /// Start position of the current drag (pixel coordinates).
  Offset? _dragStartPixel;

  /// Current position during drag (pixel coordinates).
  Offset? _dragCurrentPixel;

  /// Color of the team being dragged (for trail rendering).
  Color? _dragTeamColor;

  /// Cached default positions for both teams.
  Map<int, NormalizedPoint> _homeDefaults = const {};
  Map<int, NormalizedPoint> _awayDefaults = const {};

  @override
  void initState() {
    super.initState();
    _homeDefaults =
        _computeDefaults(widget.homeTeam, FormationLayoutBounds.topHalf);
    _awayDefaults =
        _computeDefaults(widget.awayTeam, FormationLayoutBounds.bottomHalf);
  }

  @override
  void didUpdateWidget(TacticalBoardPitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    final homeChanged = _teamChanged(oldWidget.homeTeam, widget.homeTeam);
    final awayChanged = _teamChanged(oldWidget.awayTeam, widget.awayTeam);

    if (homeChanged) {
      _homePositions.clear();
      _homeDefaults =
          _computeDefaults(widget.homeTeam, FormationLayoutBounds.topHalf);
    }
    if (awayChanged) {
      _awayPositions.clear();
      _awayDefaults =
          _computeDefaults(widget.awayTeam, FormationLayoutBounds.bottomHalf);
    }
    if (homeChanged || awayChanged) {
      _dragging = null;
    }
  }

  bool _teamChanged(LineupTeam old, LineupTeam next) =>
      old.formation != next.formation ||
      old.players.length != next.players.length;

  Map<int, NormalizedPoint> _computeDefaults(
    LineupTeam team,
    FormationLayoutBounds bounds,
  ) {
    final positioned = calculateFormationLayout(
      players: team.players,
      formation: team.formation,
      bounds: bounds,
    );
    return {for (final pp in positioned) pp.player.id: pp.position};
  }

  /// Resets all custom positions back to the formation-based layout.
  void resetPositions() {
    setState(() {
      _homePositions.clear();
      _awayPositions.clear();
      _dragging = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.config.pitchHeight,
      margin: EdgeInsets.symmetric(
        horizontal: widget.config.horizontalPadding,
        vertical: widget.config.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: widget.config.pitchColor,
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: PitchPainter(color: widget.config.lineColor),
                ),
              ),
              // Drag trail (meteor effect)
              if (_dragging != null &&
                  _dragStartPixel != null &&
                  _dragCurrentPixel != null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DragTrailPainter(
                      start: _dragStartPixel!,
                      end: _dragCurrentPixel!,
                      color: _dragTeamColor ?? Colors.white,
                    ),
                  ),
                ),
              // Away team rendered first (below home team in z-order)
              ..._buildTeamPlayers(
                widget.awayTeam,
                TacticalTeamSide.away,
                _awayDefaults,
                _awayPositions,
                w,
                h,
              ),
              // Home team on top
              ..._buildTeamPlayers(
                widget.homeTeam,
                TacticalTeamSide.home,
                _homeDefaults,
                _homePositions,
                w,
                h,
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildTeamPlayers(
    LineupTeam team,
    TacticalTeamSide side,
    Map<int, NormalizedPoint> defaults,
    Map<int, PlayerPosition> customs,
    double pitchWidth,
    double pitchHeight,
  ) {
    return team.players
        .map((player) => _buildPlayer(
              player,
              side,
              team.shirtColor,
              defaults,
              customs,
              pitchWidth,
              pitchHeight,
            ))
        .toList(growable: false);
  }

  Widget _buildPlayer(
    LineupPlayer player,
    TacticalTeamSide side,
    Color? shirtColor,
    Map<int, NormalizedPoint> defaults,
    Map<int, PlayerPosition> customs,
    double pitchWidth,
    double pitchHeight,
  ) {
    final pos = _resolvePosition(player.id, defaults, customs);
    if (pos == null) return const SizedBox.shrink();

    final left = pos.x * pitchWidth - DragVisuals.nodeWidth / 2;
    final top = pos.y * pitchHeight - DragVisuals.nodeHeight / 2;
    final isDragging = _dragging?.id == player.id && _dragging?.side == side;

    // Use AnimatedPositioned for smooth transitions when not actively dragging
    return AnimatedPositioned(
      duration: isDragging ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: left,
      top: top,
      child: GestureDetector(
        onTap: widget.onPlayerTap == null
            ? null
            : () => widget.onPlayerTap!(
                  TacticalPlayerRef(player: player, side: side),
                ),
        onPanStart: (_) => _handleDragStart(
          player.id,
          side,
          left,
          top,
          shirtColor,
        ),
        onPanUpdate: (details) => _handleDragUpdate(
          player.id,
          side,
          customs,
          left,
          top,
          details.delta,
          pitchWidth,
          pitchHeight,
        ),
        onPanEnd: (_) => _handleDragEnd(),
        child: _wrapNode(player, shirtColor, side, isDragging: isDragging),
      ),
    );
  }

  NormalizedPoint? _resolvePosition(
    int playerId,
    Map<int, NormalizedPoint> defaults,
    Map<int, PlayerPosition> customs,
  ) {
    final custom = customs[playerId];
    if (custom != null) return NormalizedPoint(custom.x, custom.y);
    return defaults[playerId];
  }

  Widget _wrapNode(
    LineupPlayer player,
    Color? shirtColor,
    TacticalTeamSide side, {
    required bool isDragging,
  }) {
    final node = widget.playerNodeBuilder != null
        ? widget.playerNodeBuilder!(player, shirtColor, side)
        : PlayerNode(
            player: player,
            shirtColor: shirtColor,
            avatarSize: widget.config.playerAvatarSize,
          );

    if (!isDragging) return node;

    // While dragging: scale up slightly for visual feedback
    return Transform.scale(
      scale: DragVisuals.dragScale,
      child: Opacity(opacity: 0.85, child: node),
    );
  }

  void _handleDragStart(
    int playerId,
    TacticalTeamSide side,
    double left,
    double top,
    Color? shirtColor,
  ) {
    widget.haptic.fire();
    setState(() {
      _dragging = (id: playerId, side: side);
      _dragStartPixel = Offset(
        left + DragVisuals.nodeWidth / 2,
        top + DragVisuals.nodeHeight / 2,
      );
      _dragCurrentPixel = _dragStartPixel;
      _dragTeamColor = shirtColor;
    });
  }

  void _handleDragUpdate(
    int playerId,
    TacticalTeamSide side,
    Map<int, PlayerPosition> customs,
    double currentLeft,
    double currentTop,
    Offset delta,
    double pitchWidth,
    double pitchHeight,
  ) {
    final newCenterX = currentLeft + delta.dx + DragVisuals.nodeWidth / 2;
    final newCenterY = currentTop + delta.dy + DragVisuals.nodeHeight / 2;

    // Full pitch — no half-restriction, only edge bounds
    final newX =
        (newCenterX / pitchWidth).clamp(DragVisuals.minX, DragVisuals.maxX);
    final newY =
        (newCenterY / pitchHeight).clamp(DragVisuals.minY, DragVisuals.maxY);

    setState(() {
      customs[playerId] = PlayerPosition(x: newX, y: newY);
      _dragCurrentPixel = Offset(
        newX * pitchWidth,
        newY * pitchHeight,
      );
    });
  }

  void _handleDragEnd() {
    setState(() {
      _dragging = null;
      _dragStartPixel = null;
      _dragCurrentPixel = null;
      _dragTeamColor = null;
    });
    widget.onPositionsChanged?.call(
      TacticalPositions(
        homePositions: Map.unmodifiable(_homePositions),
        awayPositions: Map.unmodifiable(_awayPositions),
      ),
    );
  }
}

/// Paints a fading trail line from the drag start to the current position.
///
/// Creates a "meteor tail" effect — a gradient line that fades from
/// transparent at the start to the team color at the current position.
class _DragTrailPainter extends CustomPainter {
  _DragTrailPainter({
    required this.start,
    required this.end,
    required this.color,
  });

  final Offset start;
  final Offset end;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if ((end - start).distance < 5) return; // Skip tiny movements

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromPoints(start, end))
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);

    // Small circle at start (origin indicator)
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(start, 4, dotPaint);
  }

  @override
  bool shouldRepaint(_DragTrailPainter oldDelegate) =>
      start != oldDelegate.start || end != oldDelegate.end;
}
