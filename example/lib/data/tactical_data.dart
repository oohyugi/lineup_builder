import 'package:flutter/material.dart';
import 'package:lineup_builder/lineup_builder.dart';

/// Clean tactical sample data — no names, no stats. Just numbers + positions.

final tacticalHomeTeam = LineupTeam(
  name: 'Arsenal',
  formation: '4-3-3',
  shirtColor: Colors.red.shade700,
  teamId: 1,
  players: const [
    LineupPlayer(id: 1, number: 22, position: PlayerPosition.goalkeeper),
    LineupPlayer(id: 2, number: 4, position: PlayerPosition.defender),
    LineupPlayer(id: 3, number: 2, position: PlayerPosition.defender),
    LineupPlayer(id: 4, number: 6, position: PlayerPosition.defender),
    LineupPlayer(id: 5, number: 12, position: PlayerPosition.defender),
    LineupPlayer(id: 6, number: 41, position: PlayerPosition.midfielder),
    LineupPlayer(id: 7, number: 8, position: PlayerPosition.midfielder),
    LineupPlayer(id: 8, number: 23, position: PlayerPosition.midfielder),
    LineupPlayer(id: 9, number: 7, position: PlayerPosition.forward),
    LineupPlayer(id: 10, number: 29, position: PlayerPosition.forward),
    LineupPlayer(id: 11, number: 11, position: PlayerPosition.forward),
  ],
);

final tacticalAwayTeam = LineupTeam(
  name: 'Chelsea',
  formation: '4-2-3-1',
  shirtColor: Colors.blue.shade800,
  teamId: 2,
  players: const [
    LineupPlayer(id: 20, number: 1, position: PlayerPosition.goalkeeper),
    LineupPlayer(id: 21, number: 24, position: PlayerPosition.defender),
    LineupPlayer(id: 22, number: 33, position: PlayerPosition.defender),
    LineupPlayer(id: 23, number: 26, position: PlayerPosition.defender),
    LineupPlayer(id: 24, number: 3, position: PlayerPosition.defender),
    LineupPlayer(id: 25, number: 25, position: PlayerPosition.midfielder),
    LineupPlayer(id: 26, number: 5, position: PlayerPosition.midfielder),
    LineupPlayer(id: 27, number: 11, position: PlayerPosition.midfielder),
    LineupPlayer(id: 28, number: 20, position: PlayerPosition.midfielder),
    LineupPlayer(id: 29, number: 7, position: PlayerPosition.midfielder),
    LineupPlayer(id: 30, number: 15, position: PlayerPosition.forward),
  ],
);
