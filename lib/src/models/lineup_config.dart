import 'package:flutter/services.dart';

/// Available haptic feedback types for drag interactions.
///
/// Each value maps to a specific [HapticFeedback] method from
/// Flutter's services library.
enum HapticType {
  /// A light tap sensation. Default for drag start.
  light,

  /// A medium tap sensation.
  medium,

  /// A heavy tap sensation.
  heavy,

  /// A selection click (iOS-style).
  selection,

  /// Standard vibration pattern.
  vibrate,
}

/// Configuration for haptic feedback during drag interactions.
///
/// Controls whether haptic feedback is enabled and which type of feedback
/// is triggered on drag start.
///
/// ## Example
///
/// ```dart
/// // Enabled with default (light impact):
/// const haptic = HapticConfig();
///
/// // Disabled:
/// const haptic = HapticConfig(enabled: false);
///
/// // Custom type:
/// const haptic = HapticConfig(type: HapticType.medium);
/// ```
class HapticConfig {
  /// Creates a haptic feedback configuration.
  const HapticConfig({
    this.enabled = true,
    this.type = HapticType.light,
  });

  /// Whether haptic feedback is triggered on drag start.
  ///
  /// Defaults to `true`. Set to `false` to disable all haptic feedback.
  final bool enabled;

  /// The type of haptic feedback to trigger.
  ///
  /// Defaults to [HapticType.light]. Only used when [enabled] is `true`.
  final HapticType type;

  /// Triggers the configured haptic feedback.
  ///
  /// Does nothing if [enabled] is `false`.
  void fire() {
    if (!enabled) return;
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
      case HapticType.medium:
        HapticFeedback.mediumImpact();
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
      case HapticType.selection:
        HapticFeedback.selectionClick();
      case HapticType.vibrate:
        HapticFeedback.vibrate();
    }
  }
}

/// Visual configuration for the lineup pitch widget.
///
/// Controls the appearance (colors, dimensions, padding) and the
/// single-team display mode of [LineupPitch] and [DraggableLineupPitch].
///
/// Drag-specific options live on [DraggableLineupPitch] directly
/// (see `haptic` parameter).
///
/// ## Example
///
/// ```dart
/// // Default config:
/// const config = LineupPitchConfig();
///
/// // Single-team config with custom colors and size:
/// const customConfig = LineupPitchConfig(
///   singleTeamMode: true,
///   pitchColor: Color(0xFF1B5E20),
///   pitchHeight: 600,
/// );
/// ```
///
/// ## Defaults
///
/// | Property          | Default Value          |
/// |-------------------|------------------------|
/// | pitchColor        | Dark green (ARGB)      |
/// | lineColor         | White at 20% opacity   |
/// | pitchHeight       | 800                    |
/// | borderRadius      | 16.0                   |
/// | playerAvatarSize  | 36.0                   |
/// | horizontalPadding | 16.0                   |
/// | verticalPadding   | 8.0                    |
/// | singleTeamMode    | false                  |
class LineupPitchConfig {
  /// Creates a pitch configuration.
  const LineupPitchConfig({
    this.pitchColor = const Color.fromARGB(229, 6, 76, 9),
    this.lineColor = const Color(0x33FFFFFF),
    this.pitchHeight = 800,
    this.borderRadius = 16.0,
    this.playerAvatarSize = 36.0,
    this.horizontalPadding = 16.0,
    this.verticalPadding = 8.0,
    this.singleTeamMode = false,
  });

  /// Background color of the pitch surface.
  ///
  /// Defaults to a dark green resembling a real football pitch.
  final Color pitchColor;

  /// Color used for pitch markings (halfway line, center circle,
  /// penalty areas).
  ///
  /// Typically a semi-transparent white for subtle visibility against
  /// the pitch background.
  final Color lineColor;

  /// Total height of the pitch container in logical pixels.
  ///
  /// The width is determined by parent layout constraints. A taller
  /// pitch provides more vertical space between formation rows.
  final double pitchHeight;

  /// Corner radius of the pitch container.
  ///
  /// Set to 0 for sharp corners or increase for a more rounded
  /// appearance.
  final double borderRadius;

  /// Diameter of each player's avatar circle in logical pixels.
  ///
  /// Affects the size of the circular player photo/number display.
  /// Recommended range: 28–44.
  final double playerAvatarSize;

  /// Horizontal padding (left and right) around the pitch container.
  final double horizontalPadding;

  /// Vertical padding (top and bottom) around the pitch container.
  final double verticalPadding;

  /// When `true`, the home team occupies the full pitch height.
  ///
  /// In this mode the goalkeeper is placed at the bottom and forwards
  /// at the top, using the entire vertical space. The away team is
  /// not rendered.
  ///
  /// This is automatically enabled when [LineupPitch.awayTeam] is
  /// null or has an empty players list.
  final bool singleTeamMode;
}
