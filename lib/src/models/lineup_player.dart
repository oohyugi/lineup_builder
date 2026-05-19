import 'package:flutter/material.dart';

/// Represents a single player to be rendered on the lineup pitch.
///
/// This model is completely isolated from any app-specific entity or domain
/// layer. Map your domain player objects to [LineupPlayer] before passing
/// them to lineup widgets.
///
/// ## Example
///
/// ```dart
/// final player = LineupPlayer(
///   id: 7,
///   name: 'Saka',
///   number: 7,
///   position: 'Forward',
///   gridPosition: 100,
///   rating: 8.2,
///   goals: 1,
///   assists: 1,
///   isCaptain: false,
/// );
/// ```
///
/// ## Grid Position
///
/// The [gridPosition] field determines the player's ordering within the
/// formation layout. Lower values are placed closer to the goalkeeper row,
/// higher values toward the forward line. The goalkeeper typically has a
/// value below 25.
class LineupPlayer {
  const LineupPlayer({
    required this.id,
    required this.number,
    this.name,
    this.position = '',
    this.gridPosition = 0,
    this.imageUrl,
    this.rating,
    this.isCaptain = false,
    this.isMVP = false,
    this.isSubstituted = false,
    this.isInjured = false,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.subOutMinute,
    this.subInMinute,
  });

  /// Unique identifier for this player.
  ///
  /// Used as the key in position maps and for identifying players in callbacks.
  final int id;

  /// Display name shown below the player avatar on the pitch.
  ///
  /// When `null`, the name label is hidden and only the avatar circle with
  /// the jersey number is rendered. Useful for compact tactical views.
  final String? name;

  /// Jersey/shirt number displayed inside the avatar circle when no image is
  /// available.
  final int number;

  /// Position name (e.g. "Goalkeeper", "Defender", "Midfielder", "Forward").
  ///
  /// Used internally to identify the goalkeeper for special positioning.
  /// A value of "G" or containing "goalkeeper" (case-insensitive) is treated
  /// as the GK slot.
  final String position;

  /// Numeric value used for sorting players into formation rows.
  ///
  /// Lower values are placed in defensive rows, higher values in attacking rows.
  /// The goalkeeper should have a value below 25 to be auto-detected.
  final int gridPosition;

  /// Optional URL for the player's photo or avatar image.
  ///
  /// When provided, the image is loaded via [CachedNetworkImage]. Falls back
  /// to displaying the jersey [number] if the URL is null or loading fails.
  final String? imageUrl;

  /// Optional match rating (e.g. 7.2 out of 10).
  ///
  /// Displayed as a colored badge (green >= 7, orange >= 6, red < 6) in the
  /// top-right corner of the player node.
  final double? rating;

  /// Whether this player is the team captain.
  ///
  /// When `true`, a small "C" badge is shown next to the player's name.
  final bool isCaptain;

  /// Whether this player is the Man of the Match (MVP).
  ///
  /// When `true`, a blue star badge replaces the standard rating badge.
  final bool isMVP;

  /// Whether this player was substituted out during the match.
  ///
  /// When `true`, a red substitution badge is shown at the bottom-left of
  /// the avatar.
  final bool isSubstituted;

  /// Whether this player is injured.
  ///
  /// When `true`, a medical cross icon is shown at the top-left of the avatar.
  final bool isInjured;

  /// Number of goals scored by this player in the match.
  ///
  /// Displayed as a soccer ball icon badge on the right side of the avatar.
  final int goals;

  /// Number of assists provided by this player in the match.
  ///
  /// Displayed as a handshake icon badge on the right side of the avatar.
  final int assists;

  /// Number of yellow cards received (0, 1, or 2 for second yellow).
  ///
  /// A single yellow card shows an amber card icon. Two yellow cards are
  /// displayed as a red card.
  final int yellowCards;

  /// Number of red cards received (0 or 1).
  ///
  /// Displayed as a red card icon on the left side of the avatar.
  final int redCards;

  /// Minute the player was substituted out (e.g. 72).
  ///
  /// Shown inside the substitution badge when [isSubstituted] is `true`.
  final int? subOutMinute;

  /// Minute the player was substituted in (for bench/substitute players).
  ///
  /// Useful for displaying substitution information in extended lineup views.
  final int? subInMinute;
}

/// Configuration for a team displayed on the lineup pitch.
///
/// Encapsulates all the data needed to render one side of the pitch:
/// team name, formation string, player list, and optional visual properties.
///
/// ## Example
///
/// ```dart
/// final team = LineupTeam(
///   name: 'Arsenal',
///   formation: '4-3-3',
///   players: startingXI,
///   shirtColor: Color(0xFFEF0107),
///   logoUrl: 'https://example.com/arsenal.png',
/// );
/// ```
class LineupTeam {
  const LineupTeam({
    required this.name,
    required this.formation,
    required this.players,
    this.logoUrl,
    this.shirtColor,
    this.teamId,
  });

  /// Team display name (e.g. "Arsenal", "Chelsea").
  final String name;

  /// Formation string using dash-separated row counts.
  ///
  /// Examples: "4-3-3", "4-2-3-1", "3-5-2", "5-4-1".
  /// The numbers represent outfield rows from defense to attack.
  /// The goalkeeper is positioned automatically and not included in the
  /// formation string.
  final String formation;

  /// List of starting XI players to render on the pitch.
  ///
  /// Players are sorted by [LineupPlayer.gridPosition] and distributed
  /// across formation rows automatically.
  final List<LineupPlayer> players;

  /// Optional team logo URL for display in headers or overlays.
  final String? logoUrl;

  /// Primary shirt/kit color used as the player avatar background.
  ///
  /// When null, falls back to the theme's outline color.
  final Color? shirtColor;

  /// Optional team ID for navigation or identification callbacks.
  final int? teamId;

  /// Returns a copy of this team with the given fields replaced.
  LineupTeam copyWith({
    String? name,
    String? formation,
    List<LineupPlayer>? players,
    String? logoUrl,
    Color? shirtColor,
    int? teamId,
  }) {
    return LineupTeam(
      name: name ?? this.name,
      formation: formation ?? this.formation,
      players: players ?? this.players,
      logoUrl: logoUrl ?? this.logoUrl,
      shirtColor: shirtColor ?? this.shirtColor,
      teamId: teamId ?? this.teamId,
    );
  }
}
