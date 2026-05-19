import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lineup_builder/src/models/lineup_player.dart';
import 'package:lineup_builder/src/utils/rating_color.dart';

/// Renders a single player on the pitch with contextual stat badges.
///
/// Displays the player's avatar (photo or jersey number), name, and various
/// match event badges arranged around the avatar circle.
///
/// ## Badge Layout
///
/// ```
///  [🏥 Injury]      [Rating/MVP]
///       ┌────────┐
///  [Card]│ Avatar │[⚽🅰️]
///       └────────┘
///  [↓ Sub min]
///       (C) Name
/// ```
///
/// ## Badges Shown
///
/// - **Top-left**: Injury indicator (medical cross icon)
/// - **Top-right**: Match rating (colored by tier) or MVP star badge
/// - **Mid-left**: Yellow or red card icon
/// - **Mid-right**: Goals and assists icons with counts
/// - **Bottom-left**: Substitution badge with minute
/// - **Below avatar**: Captain badge (C) + player name
///
/// ## Example
///
/// ```dart
/// PlayerNode(
///   player: myPlayer,
///   shirtColor: Colors.red,
///   avatarSize: 36,
///   onTap: () => showPlayerDetails(myPlayer),
/// )
/// ```
///
/// ## Customization
///
/// Use the `playerNodeBuilder` parameter on [LineupPitch] or
/// [DraggableLineupPitch] to replace this widget with a fully custom
/// player representation.
class PlayerNode extends StatelessWidget {
  /// Creates a player node widget.
  ///
  /// The [player] parameter provides all data for rendering badges and info.
  /// The optional [shirtColor] sets the avatar background color.
  const PlayerNode({
    super.key,
    required this.player,
    this.shirtColor,
    this.avatarSize = 36,
    this.onTap,
  });

  /// The player data to render (name, number, stats, badges).
  final LineupPlayer player;

  /// Background color for the player's avatar circle.
  ///
  /// Typically the team's primary kit color. Falls back to the theme's
  /// outline color when null.
  final Color? shirtColor;

  /// Diameter of the avatar circle in logical pixels.
  ///
  /// Defaults to 36. Recommended range: 28–44 for readability.
  final double avatarSize;

  /// Optional tap callback for this player node.
  ///
  /// When provided, the entire node becomes tappable. Used for showing
  /// player detail sheets or navigation.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.onPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Avatar + badges ────────────────────────────────────────────
          SizedBox(
            width: 60,
            height: 46,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Avatar
                _PlayerAvatar(
                  imageUrl: player.imageUrl,
                  number: player.number,
                  size: avatarSize,
                  backgroundColor: shirtColor,
                  borderColor: borderColor,
                ),

                // ── Top-Left: Injury ─────────────────────────────────────
                if (player.isInjured)
                  Positioned(
                    top: -2,
                    left: 2,
                    child: _CircleIcon(
                      size: 13,
                      color: Colors.white,
                      borderColor: borderColor,
                      child: const Icon(Icons.add_rounded,
                          size: 10, color: Colors.red),
                    ),
                  ),

                // ── Top-Right: Rating / MVP ──────────────────────────────
                if (player.isMVP)
                  Positioned(
                    top: -3,
                    right: -2,
                    child: _MvpBadge(
                        rating: player.rating, borderColor: borderColor),
                  )
                else if (player.rating != null)
                  Positioned(
                    top: -3,
                    right: -2,
                    child: _RatingBadge(
                        rating: player.rating!, borderColor: borderColor),
                  ),

                // ── Mid-Left: Card ───────────────────────────────────────
                if (player.redCards > 0 || player.yellowCards == 2)
                  Positioned(
                    top: 15,
                    left: 2,
                    child:
                        _CardIcon(color: Colors.red, borderColor: borderColor),
                  )
                else if (player.yellowCards == 1)
                  Positioned(
                    top: 15,
                    left: 2,
                    child: _CardIcon(
                        color: Colors.amber, borderColor: borderColor),
                  ),

                // ── Mid-Right: Goals & Assists ───────────────────────────
                if (player.goals > 0 || player.assists > 0)
                  Positioned(
                    top: 18,
                    right: -2,
                    child: _GoalAssistBadge(
                        goals: player.goals, assists: player.assists),
                  ),

                // ── Bottom-Left: Substitution out ────────────────────────
                if (player.isSubstituted)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _SubBadge(
                        minute: player.subOutMinute, borderColor: borderColor),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),

          // ── Name row (Captain inline) — hidden when player.name is null ──
          if (player.name != null)
            SizedBox(
              width: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (player.isCaptain) ...[
                    Container(
                      width: 10,
                      height: 10,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'C',
                        style: TextStyle(
                          fontSize: 6,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  Flexible(
                    child: Text(
                      '${player.number}. ${player.name}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Circular avatar showing the player's photo or jersey number as fallback.
class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({
    this.imageUrl,
    required this.number,
    required this.size,
    this.backgroundColor,
    required this.borderColor,
  });
  final String? imageUrl;
  final int number;
  final double size;
  final Color? backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.outline;
    final bool isDark = bgColor.computeLuminance() < 0.3;
    final Color fallbackColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Center(
                  child: Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.bold,
                      color: fallbackColor,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.bold,
                      color: fallbackColor,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: size * 0.3,
                    fontWeight: FontWeight.bold,
                    color: fallbackColor,
                  ),
                ),
              ),
      ),
    );
  }
}

/// Blue badge with star icon for Man of the Match, optionally showing rating.
class _MvpBadge extends StatelessWidget {
  const _MvpBadge({this.rating, required this.borderColor});
  final double? rating;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 9),
          if (rating != null) ...[
            const SizedBox(width: 1),
            Text(
              rating!.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Colored rating badge (green/orange/red based on value).
class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating, required this.borderColor});
  final double rating;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final color = getRatingColor(rating);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Text(
        rating.toStringAsFixed(1),
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

/// Red badge indicating substitution out, with optional minute display.
class _SubBadge extends StatelessWidget {
  const _SubBadge({this.minute, required this.borderColor});
  final int? minute;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.south_rounded, size: 8, color: Colors.white),
          if (minute != null) ...[
            const SizedBox(width: 1),
            Text(
              "$minute'",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Badge showing goal and/or assist icons with counts.
class _GoalAssistBadge extends StatelessWidget {
  const _GoalAssistBadge({required this.goals, required this.assists});
  final int goals;
  final int assists;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (goals > 0) ...[
            Icon(Icons.sports_soccer, size: 9, color: Colors.grey.shade800),
            if (goals > 1)
              Text(
                '$goals',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  height: 1,
                ),
              ),
          ],
          if (goals > 0 && assists > 0) const SizedBox(width: 2),
          if (assists > 0) ...[
            Icon(Icons.handshake_outlined,
                size: 9, color: Colors.grey.shade600),
            if (assists > 1)
              Text(
                '$assists',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  height: 1,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Small colored rectangle representing a yellow or red card.
class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.color, required this.borderColor});
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.5),
        border: Border.all(color: borderColor, width: 0.5),
      ),
    );
  }
}

/// Generic circular icon container used for injury and other indicators.
class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.size,
    required this.color,
    required this.borderColor,
    required this.child,
  });
  final double size;
  final Color color;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: child,
    );
  }
}
