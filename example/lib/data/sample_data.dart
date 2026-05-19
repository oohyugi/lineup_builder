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
      id: 1, name: 'Raya', number: 22,
      position: 'Goalkeeper', gridPosition: 1,
      rating: 7.1,
    ),
    const LineupPlayer(
      id: 2, name: 'White', number: 4,
      position: 'Defender', gridPosition: 31,
      rating: 6.5, yellowCards: 1,
    ),
    const LineupPlayer(
      id: 3, name: 'Saliba', number: 2,
      position: 'Defender', gridPosition: 32,
      rating: 7.8, isCaptain: true,
    ),
    const LineupPlayer(
      id: 4, name: 'Gabriel', number: 6,
      position: 'Defender', gridPosition: 33,
      rating: 7.2, goals: 1,
    ),
    const LineupPlayer(
      id: 5, name: 'Timber', number: 12,
      position: 'Defender', gridPosition: 34,
      rating: 6.9,
    ),
    const LineupPlayer(
      id: 6, name: 'Rice', number: 41,
      position: 'Midfielder', gridPosition: 51,
      rating: 7.5, assists: 1,
    ),
    const LineupPlayer(
      id: 7, name: 'Odegaard', number: 8,
      position: 'Midfielder', gridPosition: 52,
      rating: 8.2, isMVP: true, goals: 1, assists: 1,
    ),
    const LineupPlayer(
      id: 8, name: 'Merino', number: 23,
      position: 'Midfielder', gridPosition: 53,
      rating: 6.8, isSubstituted: true, subOutMinute: 72,
    ),
    const LineupPlayer(
      id: 9, name: 'Saka', number: 7,
      position: 'Forward', gridPosition: 71,
      rating: 7.9, goals: 2,
    ),
    const LineupPlayer(
      id: 10, name: 'Havertz', number: 29,
      position: 'Forward', gridPosition: 72,
      rating: 6.4, isSubstituted: true, subOutMinute: 65,
    ),
    const LineupPlayer(
      id: 11, name: 'Martinelli', number: 11,
      position: 'Forward', gridPosition: 73,
      rating: 7.0, isSubstituted: true, subOutMinute: 80,
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
      id: 20, name: 'Sanchez', number: 1,
      position: 'Goalkeeper', gridPosition: 1,
      rating: 6.1,
    ),
    const LineupPlayer(
      id: 21, name: 'James', number: 24,
      position: 'Defender', gridPosition: 31,
      rating: 6.2, isInjured: true,
    ),
    const LineupPlayer(
      id: 22, name: 'Fofana', number: 33,
      position: 'Defender', gridPosition: 32,
      rating: 6.5,
    ),
    const LineupPlayer(
      id: 23, name: 'Colwill', number: 26,
      position: 'Defender', gridPosition: 33,
      rating: 6.8, yellowCards: 1,
    ),
    const LineupPlayer(
      id: 24, name: 'Cucurella', number: 3,
      position: 'Defender', gridPosition: 34,
      rating: 6.0,
    ),
    const LineupPlayer(
      id: 25, name: 'Caicedo', number: 25,
      position: 'Midfielder', gridPosition: 51,
      rating: 7.0, isCaptain: true,
    ),
    const LineupPlayer(
      id: 26, name: 'Fernandez', number: 5,
      position: 'Midfielder', gridPosition: 52,
      rating: 5.8, redCards: 1,
    ),
    const LineupPlayer(
      id: 27, name: 'Madueke', number: 11,
      position: 'Midfielder', gridPosition: 61,
      rating: 6.3,
    ),
    const LineupPlayer(
      id: 28, name: 'Palmer', number: 20,
      position: 'Midfielder', gridPosition: 62,
      rating: 7.4, goals: 1,
    ),
    const LineupPlayer(
      id: 29, name: 'Neto', number: 7,
      position: 'Midfielder', gridPosition: 63,
      rating: 5.9, isSubstituted: true, subOutMinute: 58,
    ),
    const LineupPlayer(
      id: 30, name: 'Jackson', number: 15,
      position: 'Forward', gridPosition: 71,
      rating: 6.6, assists: 1,
    ),
  ],
);

/// Sample squad for builder mode
final sampleSquad = [
  const LineupPlayer(id: 1, name: 'Raya', number: 22, position: 'Goalkeeper', gridPosition: 1),
  const LineupPlayer(id: 2, name: 'White', number: 4, position: 'Defender', gridPosition: 31),
  const LineupPlayer(id: 3, name: 'Saliba', number: 2, position: 'Defender', gridPosition: 32),
  const LineupPlayer(id: 4, name: 'Gabriel', number: 6, position: 'Defender', gridPosition: 33),
  const LineupPlayer(id: 5, name: 'Timber', number: 12, position: 'Defender', gridPosition: 34),
  const LineupPlayer(id: 6, name: 'Zinchenko', number: 35, position: 'Defender', gridPosition: 35),
  const LineupPlayer(id: 7, name: 'Rice', number: 41, position: 'Midfielder', gridPosition: 51),
  const LineupPlayer(id: 8, name: 'Odegaard', number: 8, position: 'Midfielder', gridPosition: 52),
  const LineupPlayer(id: 9, name: 'Merino', number: 23, position: 'Midfielder', gridPosition: 53),
  const LineupPlayer(id: 10, name: 'Partey', number: 5, position: 'Midfielder', gridPosition: 54),
  const LineupPlayer(id: 11, name: 'Saka', number: 7, position: 'Forward', gridPosition: 71),
  const LineupPlayer(id: 12, name: 'Havertz', number: 29, position: 'Forward', gridPosition: 72),
  const LineupPlayer(id: 13, name: 'Martinelli', number: 11, position: 'Forward', gridPosition: 73),
  const LineupPlayer(id: 14, name: 'Trossard', number: 19, position: 'Forward', gridPosition: 74),
  const LineupPlayer(id: 15, name: 'Jesus', number: 9, position: 'Forward', gridPosition: 75),
  const LineupPlayer(id: 16, name: 'Nketiah', number: 14, position: 'Forward', gridPosition: 76),
];
