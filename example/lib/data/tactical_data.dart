import 'package:flutter/material.dart';
import 'package:lineup_builder/lineup_builder.dart';

/// Clean tactical sample data — no names, no stats. Just numbers + positions.

final tacticalHomeTeam = LineupTeam(
  name: 'Arsenal',
  formation: '4-3-3',
  shirtColor: Colors.red.shade700,
  teamId: 1,
  players: const [
    LineupPlayer(id: 1, number: 22, position: 'Goalkeeper', gridPosition: 1),
    LineupPlayer(id: 2, number: 4, position: 'Defender', gridPosition: 31),
    LineupPlayer(id: 3, number: 2, position: 'Defender', gridPosition: 32),
    LineupPlayer(id: 4, number: 6, position: 'Defender', gridPosition: 33),
    LineupPlayer(id: 5, number: 12, position: 'Defender', gridPosition: 34),
    LineupPlayer(id: 6, number: 41, position: 'Midfielder', gridPosition: 51),
    LineupPlayer(id: 7, number: 8, position: 'Midfielder', gridPosition: 52),
    LineupPlayer(id: 8, number: 23, position: 'Midfielder', gridPosition: 53),
    LineupPlayer(id: 9, number: 7, position: 'Forward', gridPosition: 71),
    LineupPlayer(id: 10, number: 29, position: 'Forward', gridPosition: 72),
    LineupPlayer(id: 11, number: 11, position: 'Forward', gridPosition: 73),
  ],
);

final tacticalAwayTeam = LineupTeam(
  name: 'Chelsea',
  formation: '4-2-3-1',
  shirtColor: Colors.blue.shade800,
  teamId: 2,
  players: const [
    LineupPlayer(id: 20, number: 1, position: 'Goalkeeper', gridPosition: 1),
    LineupPlayer(id: 21, number: 24, position: 'Defender', gridPosition: 31),
    LineupPlayer(id: 22, number: 33, position: 'Defender', gridPosition: 32),
    LineupPlayer(id: 23, number: 26, position: 'Defender', gridPosition: 33),
    LineupPlayer(id: 24, number: 3, position: 'Defender', gridPosition: 34),
    LineupPlayer(id: 25, number: 25, position: 'Midfielder', gridPosition: 51),
    LineupPlayer(id: 26, number: 5, position: 'Midfielder', gridPosition: 52),
    LineupPlayer(id: 27, number: 11, position: 'Midfielder', gridPosition: 61),
    LineupPlayer(id: 28, number: 20, position: 'Midfielder', gridPosition: 62),
    LineupPlayer(id: 29, number: 7, position: 'Midfielder', gridPosition: 63),
    LineupPlayer(id: 30, number: 15, position: 'Forward', gridPosition: 71),
  ],
);
