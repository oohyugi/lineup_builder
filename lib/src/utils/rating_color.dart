import 'package:flutter/material.dart';

/// Returns a color representing the quality tier of a player's match rating.
///
/// The color coding follows standard football rating conventions:
///
/// | Rating Range | Color   | Meaning          |
/// |--------------|---------|------------------|
/// | >= 7.0       | Green   | Good to excellent|
/// | >= 6.0       | Orange  | Average          |
/// | < 6.0        | Red     | Below average    |
///
/// ## Example
///
/// ```dart
/// final color = getRatingColor(7.5); // Colors.green
/// final color2 = getRatingColor(6.3); // Colors.orange
/// final color3 = getRatingColor(5.1); // Colors.red
/// ```
///
/// Used internally by [PlayerNode] to color the rating badge, but can also
/// be used externally for consistent rating color coding across your app.
Color getRatingColor(double rating) {
  if (rating >= 7.0) return Colors.green;
  if (rating >= 6.0) return Colors.orange;
  return Colors.red;
}
