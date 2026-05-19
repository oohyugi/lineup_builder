/// Visual constants for drag interactions, shared across draggable widgets.
abstract final class DragVisuals {
  /// Scale factor applied to the player node while being dragged.
  static const double dragScale = 1.1;

  /// Glow effect blur radius during drag.
  static const double glowBlurRadius = 12.0;

  /// Glow effect spread radius during drag.
  static const double glowSpreadRadius = 2.0;

  /// Glow color alpha during drag.
  static const double glowAlpha = 0.3;

  /// Player node bounding box width (matches PlayerNode internal size).
  static const double nodeWidth = 60.0;

  /// Player node bounding box height (matches PlayerNode internal size).
  static const double nodeHeight = 56.0;

  /// Min/max bounds for normalized X during drag (keeps node visible).
  static const double minX = 0.05;
  static const double maxX = 0.95;

  /// Min/max bounds for normalized Y during drag.
  static const double minY = 0.03;
  static const double maxY = 0.97;
}

/// Formation label shown when positions are manually overridden.
const String freeFormationLabel = 'Free';
