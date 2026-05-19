/// Parses a formation string into a list of row counts (outfield only).
///
/// Takes a dash-separated formation string (e.g. "4-3-3") and returns a list
/// of integers representing the number of players in each row from defense
/// to attack: `[4, 3, 3]`.
///
/// The goalkeeper is not included in the formation string and is positioned
/// separately by the pitch widgets.
///
/// ## Examples
///
/// ```dart
/// parseFormation('4-3-3');    // [4, 3, 3]
/// parseFormation('4-2-3-1'); // [4, 2, 3, 1]
/// parseFormation('3-5-2');   // [3, 5, 2]
/// parseFormation('');        // [4, 4, 2] (fallback)
/// parseFormation('invalid'); // [4, 4, 2] (fallback)
/// ```
///
/// ## Fallback
///
/// Returns `[4, 4, 2]` if the input is empty or cannot be parsed as
/// dash-separated integers.
List<int> parseFormation(String formation) {
  if (formation.isEmpty) return [4, 4, 2];
  try {
    return formation.split('-').map((e) => int.parse(e.trim())).toList();
  } catch (_) {
    return [4, 4, 2];
  }
}
