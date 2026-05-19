import 'package:flutter/material.dart';
import 'package:lineup_builder/src/models/lineup_config.dart';
import 'package:lineup_builder/src/models/lineup_player.dart';
import 'package:lineup_builder/src/utils/drag_constants.dart';
import 'package:lineup_builder/src/utils/formation_layout.dart';
import 'package:lineup_builder/src/widgets/pitch_painter.dart';
import 'package:lineup_builder/src/widgets/player_node.dart';

/// Normalized position of a player on the pitch.
///
/// Both [x] and [y] are values between 0.0 and 1.0, representing the
/// player's position as a fraction of the pitch dimensions:
/// - `x = 0.0` is the left edge, `x = 1.0` is the right edge
/// - `y = 0.0` is the top edge, `y = 1.0` is the bottom edge
///
/// ## Example
///
/// ```dart
/// // Center of the pitch
/// const center = PitchPosition(x: 0.5, y: 0.5);
/// ```
class PitchPosition {
  /// Creates a normalized player position.
  const PitchPosition({required this.x, required this.y});

  /// Horizontal position (0.0 = left edge, 1.0 = right edge).
  final double x;

  /// Vertical position (0.0 = top edge, 1.0 = bottom edge).
  final double y;
}

/// Formation label shown when positions are manually overridden.
// (Defined in drag_constants.dart)

/// A stateful lineup pitch widget that supports drag-and-drop repositioning
/// of players with haptic feedback and visual drag indicators.
///
/// When a player is dragged, the formation label becomes "Free" and
/// [onPositionsChanged] fires with the updated positions map.
///
/// ## Drag Interaction
///
/// - **On drag start**: Triggers haptic feedback (configurable via [haptic])
///   and scales the player node up to 1.1× with a subtle glow effect.
/// - **During drag**: The player follows the pointer with the scale and
///   glow effect active.
/// - **On drag end**: The scale and glow reset, and [onPositionsChanged]
///   fires with the final positions.
///
/// ## Example
///
/// ```dart
/// DraggableLineupPitch(
///   team: LineupTeam(
///     name: 'Arsenal',
///     formation: '4-3-3',
///     players: startingXI,
///     shirtColor: Colors.red,
///   ),
///   onPositionsChanged: (positions) => save(positions),
///   onFormationChanged: (formation) => updateLabel(formation),
///   onPlayerTap: (player) => showPlayerDetails(player),
/// )
/// ```
///
/// ## Resetting Positions
///
/// Use a [GlobalKey] to access the state and call `resetPositions()`:
///
/// ```dart
/// final key = GlobalKey<State<DraggableLineupPitch>>();
/// // ... pass key to the widget ...
/// (key.currentState as dynamic)?.resetPositions();
/// ```
class DraggableLineupPitch extends StatefulWidget {
  /// Creates a draggable lineup pitch.
  const DraggableLineupPitch({
    super.key,
    required this.team,
    this.config = const LineupPitchConfig(singleTeamMode: true),
    this.haptic = const HapticConfig(),
    this.onPlayerTap,
    this.onPositionsChanged,
    this.onFormationChanged,
    this.playerNodeBuilder,
  });

  /// The team to display on the pitch.
  ///
  /// Players are positioned according to [LineupTeam.formation] initially,
  /// and can be freely repositioned via drag gestures.
  final LineupTeam team;

  /// Visual and behavioral configuration for the pitch.
  ///
  /// Defaults to single-team mode since the draggable pitch is typically
  /// used for editing a single team's formation.
  final LineupPitchConfig config;

  /// Haptic feedback configuration for drag interactions.
  ///
  /// Defaults to enabled with [HapticType.light]. Pass
  /// `HapticConfig(enabled: false)` to disable.
  final HapticConfig haptic;

  /// Callback when a player is tapped (not dragged).
  final void Function(LineupPlayer player)? onPlayerTap;

  /// Called when player positions change after a drag completes.
  ///
  /// The map key is the player's [LineupPlayer.id], and the value is the
  /// new normalized [PitchPosition]. Only contains entries for players
  /// that have been manually repositioned.
  final void Function(Map<int, PitchPosition> positions)? onPositionsChanged;

  /// Called when the formation label changes.
  ///
  /// Fires with `"Free"` the first time any player is dragged. Also fires
  /// with the original formation string when `resetPositions()` is called.
  final void Function(String formation)? onFormationChanged;

  /// Optional custom builder for player nodes.
  ///
  /// The drag scale and glow effects are applied around the custom widget.
  final Widget Function(LineupPlayer player, Color? shirtColor)?
      playerNodeBuilder;

  @override
  State<DraggableLineupPitch> createState() => _DraggableLineupPitchState();
}

class _DraggableLineupPitchState extends State<DraggableLineupPitch> {
  /// Custom positions for players that have been dragged.
  final Map<int, PitchPosition> _customPositions = {};

  /// ID of the player currently being dragged, or null if no drag active.
  int? _draggingPlayerId;

  /// Whether the formation has been modified by dragging.
  bool _isFreeFormation = false;

  /// Drag trail tracking.
  Offset? _dragStartPixel;
  Offset? _dragCurrentPixel;

  /// Cached default formation positions to avoid recalculating on every
  /// drag update.
  Map<int, NormalizedPoint> _defaultPositions = const {};

  @override
  void initState() {
    super.initState();
    _defaultPositions = _computeDefaultPositions();
  }

  @override
  void didUpdateWidget(DraggableLineupPitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    final teamChanged = oldWidget.team.formation != widget.team.formation ||
        oldWidget.team.players.length != widget.team.players.length;

    if (teamChanged) {
      _customPositions.clear();
      _isFreeFormation = false;
      _draggingPlayerId = null;
      _defaultPositions = _computeDefaultPositions();
    }
  }

  /// Computes the formation-based default positions for all players.
  Map<int, NormalizedPoint> _computeDefaultPositions() {
    final positioned = calculateFormationLayout(
      players: widget.team.players,
      formation: widget.team.formation,
      bounds: FormationLayoutBounds.fullPitch,
    );
    return {
      for (final pp in positioned) pp.player.id: pp.position,
    };
  }

  /// Resets all custom positions back to the formation-based layout.
  void resetPositions() {
    if (_customPositions.isEmpty && !_isFreeFormation) return;

    setState(() {
      _customPositions.clear();
      _isFreeFormation = false;
      _draggingPlayerId = null;
    });
    widget.onFormationChanged?.call(widget.team.formation);
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
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: PitchPainter(color: widget.config.lineColor),
                ),
              ),
              // Drag trail
              if (_draggingPlayerId != null &&
                  _dragStartPixel != null &&
                  _dragCurrentPixel != null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DragTrailPainter(
                      start: _dragStartPixel!,
                      end: _dragCurrentPixel!,
                      color: widget.team.shirtColor ?? Colors.white,
                    ),
                  ),
                ),
              ..._buildDraggablePlayers(
                constraints.maxWidth,
                constraints.maxHeight,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds positioned, draggable widgets for every player.
  List<Widget> _buildDraggablePlayers(double pitchWidth, double pitchHeight) {
    return widget.team.players
        .map((player) => _buildDraggablePlayer(player, pitchWidth, pitchHeight))
        .toList(growable: false);
  }

  /// Builds a single draggable player widget with gesture handlers.
  Widget _buildDraggablePlayer(
    LineupPlayer player,
    double pitchWidth,
    double pitchHeight,
  ) {
    final pos = _resolvePosition(player.id);
    if (pos == null) return const SizedBox.shrink();

    final left = pos.x * pitchWidth - DragVisuals.nodeWidth / 2;
    final top = pos.y * pitchHeight - DragVisuals.nodeHeight / 2;
    final isDragging = _draggingPlayerId == player.id;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: widget.onPlayerTap == null
            ? null
            : () => widget.onPlayerTap!(player),
        onPanStart: (_) => _handleDragStart(player.id),
        onPanUpdate: (details) => _handleDragUpdate(
          player.id,
          left,
          top,
          details.delta,
          pitchWidth,
          pitchHeight,
        ),
        onPanEnd: (_) => _handleDragEnd(),
        child: _wrapPlayerNode(
          player,
          widget.team.shirtColor,
          isDragging: isDragging,
        ),
      ),
    );
  }

  /// Returns the current position of a player (custom override or default).
  NormalizedPoint? _resolvePosition(int playerId) {
    final custom = _customPositions[playerId];
    if (custom != null) {
      return NormalizedPoint(custom.x, custom.y);
    }
    return _defaultPositions[playerId];
  }

  /// Builds the player node and applies drag visual effects when dragging.
  Widget _wrapPlayerNode(
    LineupPlayer player,
    Color? shirtColor, {
    required bool isDragging,
  }) {
    final node = widget.playerNodeBuilder != null
        ? widget.playerNodeBuilder!(player, shirtColor)
        : PlayerNode(
            player: player,
            shirtColor: shirtColor,
            avatarSize: widget.config.playerAvatarSize,
          );

    if (!isDragging) return node;

    return Transform.scale(
      scale: DragVisuals.dragScale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: DragVisuals.glowAlpha),
              blurRadius: DragVisuals.glowBlurRadius,
              spreadRadius: DragVisuals.glowSpreadRadius,
            ),
          ],
        ),
        child: node,
      ),
    );
  }

  void _handleDragStart(int playerId) {
    widget.haptic.fire();
    final pos = _resolvePosition(playerId);
    setState(() {
      _draggingPlayerId = playerId;
      if (pos != null) {
        // We'll set actual pixel positions on first update
        _dragStartPixel = null;
        _dragCurrentPixel = null;
      }
    });
  }

  void _handleDragUpdate(
    int playerId,
    double currentLeft,
    double currentTop,
    Offset delta,
    double pitchWidth,
    double pitchHeight,
  ) {
    final newCenterX = currentLeft + delta.dx + DragVisuals.nodeWidth / 2;
    final newCenterY = currentTop + delta.dy + DragVisuals.nodeHeight / 2;

    final newX =
        (newCenterX / pitchWidth).clamp(DragVisuals.minX, DragVisuals.maxX);
    final newY =
        (newCenterY / pitchHeight).clamp(DragVisuals.minY, DragVisuals.maxY);

    setState(() {
      _customPositions[playerId] = PitchPosition(x: newX, y: newY);
      // Set start pixel on first drag update
      _dragStartPixel ??= Offset(
        currentLeft + DragVisuals.nodeWidth / 2,
        currentTop + DragVisuals.nodeHeight / 2,
      );
      _dragCurrentPixel = Offset(newX * pitchWidth, newY * pitchHeight);
    });

    if (!_isFreeFormation) {
      _isFreeFormation = true;
      widget.onFormationChanged?.call(freeFormationLabel);
    }
  }

  void _handleDragEnd() {
    setState(() {
      _draggingPlayerId = null;
      _dragStartPixel = null;
      _dragCurrentPixel = null;
    });
    widget.onPositionsChanged?.call(Map.unmodifiable(_customPositions));
  }
}

/// Paints a fading trail line from the drag start to the current position.
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
    if ((end - start).distance < 5) return;

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
