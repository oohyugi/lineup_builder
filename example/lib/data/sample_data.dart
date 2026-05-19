import 'package:flutter/material.dart';
import 'package:lineup_builder/lineup_builder.dart';

/// Sample Arsenal lineup (4-3-3)
final arsenalTeam = LineupTeam(
  name: 'Arsenal',
  formation: '4-3-3',
  shirtColor: Colors.red.shade700,
  logoUrl: null,
  teamId: 1,
  players: [
    const LineupPlayer(
      id: 1,
      name: 'Raya',
      number: 22,
      position: PlayerPosition.goalkeeper,
      rating: 7.1,
    ),
    const LineupPlayer(
      id: 2,
      name: 'White',
      number: 4,
      position: PlayerPosition.defender,
      rating: 6.5,
      yellowCards: 1,
    ),
    const LineupPlayer(
      id: 3,
      name: 'Saliba',
      number: 2,
      position: PlayerPosition.defender,
      rating: 7.8,
      isCaptain: true,
    ),
    const LineupPlayer(
      id: 4,
      name: 'Gabriel',
      number: 6,
      position: PlayerPosition.defender,
      rating: 7.2,
      goals: 1,
    ),
    const LineupPlayer(
      id: 5,
      name: 'Timber',
      number: 12,
      position: PlayerPosition.defender,
      rating: 6.9,
    ),
    const LineupPlayer(
      id: 6,
      name: 'Rice',
      number: 41,
      position: PlayerPosition.midfielder,
      rating: 7.5,
      assists: 1,
    ),
    const LineupPlayer(
      id: 7,
      name: 'Odegaard',
      number: 8,
      position: PlayerPosition.midfielder,
      rating: 8.2,
      isMVP: true,
      goals: 1,
      assists: 1,
    ),
    const LineupPlayer(
      id: 8,
      name: 'Merino',
      number: 23,
      position: PlayerPosition.midfielder,
      rating: 6.8,
      isSubstituted: true,
      subOutMinute: 72,
    ),
    const LineupPlayer(
      id: 9,
      name: 'Saka',
      number: 7,
      position: PlayerPosition.forward,
      rating: 7.9,
      goals: 2,
    ),
    const LineupPlayer(
      id: 10,
      name: 'Havertz',
      number: 29,
      position: PlayerPosition.forward,
      rating: 6.4,
      isSubstituted: true,
      subOutMinute: 65,
    ),
    const LineupPlayer(
      id: 11,
      name: 'Martinelli',
      number: 11,
      position: PlayerPosition.forward,
      rating: 7.0,
      isSubstituted: true,
      subOutMinute: 80,
    ),
  ],
);

/// Sample Chelsea lineup (4-2-3-1)
final chelseaTeam = LineupTeam(
  name: 'Chelsea',
  formation: '4-2-3-1',
  shirtColor: Colors.blue.shade800,
  logoUrl: null,
  teamId: 2,
  players: [
    const LineupPlayer(
      id: 20,
      name: 'Sanchez',
      number: 1,
      position: PlayerPosition.goalkeeper,
      rating: 6.1,
    ),
    const LineupPlayer(
      id: 21,
      name: 'James',
      number: 24,
      position: PlayerPosition.defender,
      rating: 6.2,
      isInjured: true,
    ),
    const LineupPlayer(
      id: 22,
      name: 'Fofana',
      number: 33,
      position: PlayerPosition.defender,
      rating: 6.5,
    ),
    const LineupPlayer(
      id: 23,
      name: 'Colwill',
      number: 26,
      position: PlayerPosition.defender,
      rating: 6.8,
      yellowCards: 1,
    ),
    const LineupPlayer(
      id: 24,
      name: 'Cucurella',
      number: 3,
      position: PlayerPosition.defender,
      rating: 6.0,
    ),
    const LineupPlayer(
      id: 25,
      name: 'Caicedo',
      number: 25,
      position: PlayerPosition.midfielder,
      rating: 7.0,
      isCaptain: true,
    ),
    const LineupPlayer(
      id: 26,
      name: 'Fernandez',
      number: 5,
      position: PlayerPosition.midfielder,
      rating: 5.8,
      redCards: 1,
    ),
    const LineupPlayer(
      id: 27,
      name: 'Madueke',
      number: 11,
      position: PlayerPosition.midfielder,
      rating: 6.3,
    ),
    const LineupPlayer(
      id: 28,
      name: 'Palmer',
      number: 20,
      position: PlayerPosition.midfielder,
      rating: 7.4,
      goals: 1,
    ),
    const LineupPlayer(
      id: 29,
      name: 'Neto',
      number: 7,
      position: PlayerPosition.midfielder,
      rating: 5.9,
      isSubstituted: true,
      subOutMinute: 58,
    ),
    const LineupPlayer(
      id: 30,
      name: 'Jackson',
      number: 15,
      position: PlayerPosition.forward,
      rating: 6.6,
      assists: 1,
    ),
  ],
);

/// Sample squad for builder mode
final sampleSquad = [
  const LineupPlayer(
      id: 1, name: 'Raya', number: 22, position: PlayerPosition.goalkeeper),
  const LineupPlayer(
      id: 2, name: 'White', number: 4, position: PlayerPosition.defender),
  const LineupPlayer(
      id: 3, name: 'Saliba', number: 2, position: PlayerPosition.defender),
  const LineupPlayer(
      id: 4, name: 'Gabriel', number: 6, position: PlayerPosition.defender),
  const LineupPlayer(
      id: 5, name: 'Timber', number: 12, position: PlayerPosition.defender),
  const LineupPlayer(
      id: 6, name: 'Zinchenko', number: 35, position: PlayerPosition.defender),
  const LineupPlayer(
      id: 7, name: 'Rice', number: 41, position: PlayerPosition.midfielder),
  const LineupPlayer(
      id: 8, name: 'Odegaard', number: 8, position: PlayerPosition.midfielder),
  const LineupPlayer(
      id: 9, name: 'Merino', number: 23, position: PlayerPosition.midfielder),
  const LineupPlayer(
      id: 10, name: 'Partey', number: 5, position: PlayerPosition.midfielder),
  const LineupPlayer(
      id: 11, name: 'Saka', number: 7, position: PlayerPosition.forward),
  const LineupPlayer(
      id: 12, name: 'Havertz', number: 29, position: PlayerPosition.forward),
  const LineupPlayer(
      id: 13, name: 'Martinelli', number: 11, position: PlayerPosition.forward),
  const LineupPlayer(
      id: 14, name: 'Trossard', number: 19, position: PlayerPosition.forward),
  const LineupPlayer(
      id: 15, name: 'Jesus', number: 9, position: PlayerPosition.forward),
  const LineupPlayer(
      id: 16, name: 'Nketiah', number: 14, position: PlayerPosition.forward),
];
