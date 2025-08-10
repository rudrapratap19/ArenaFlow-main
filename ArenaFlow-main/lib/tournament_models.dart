import 'package:cloud_firestore/cloud_firestore.dart';

enum TournamentType {
  singleElimination,
  doubleElimination,
  roundRobin,
}

enum TournamentStatus {
  registration,
  inProgress,
  completed,
}

enum MatchType {
  groupStage,
  roundOf16,
  quarterFinal,
  semiFinal,
  finall,
  thirdPlace,
  // For double elimination
  winnerBracket,
  loserBracket,
  grandFinal,
}

class Tournament {
  final String id;
  final String name;
  final String sport;
  final TournamentType type;
  final TournamentStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> teamIds;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final String createdBy;

  Tournament({
    required this.id,
    required this.name,
    required this.sport,
    required this.type,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.teamIds,
    required this.settings,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sport': sport,
      'type': type.toString(),
      'status': status.toString(),
      'startDate': startDate,
      'endDate': endDate,
      'teamIds': teamIds,
      'settings': settings,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }

  static Tournament fromMap(String id, Map<String, dynamic> map) {
    return Tournament(
      id: id,
      name: map['name'] ?? '',
      sport: map['sport'] ?? '',
      type: TournamentType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => TournamentType.singleElimination,
      ),
      status: TournamentStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => TournamentStatus.registration,
      ),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      teamIds: List<String>.from(map['teamIds'] ?? []),
      settings: map['settings'] ?? {},
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }
}

class TournamentMatch {
  final String id;
  final String tournamentId;
  final String? team1Id;
  final String? team2Id;
  final String? team1Name;
  final String? team2Name;
  final int team1Score;
  final int team2Score;
  final String? winnerId;
  final String? loserId;
  final MatchType matchType;
  final int round;
  final int position;
  final String status;
  final DateTime? scheduledTime;
  final String venue;
  final Map<String, dynamic> metadata;

  TournamentMatch({
    required this.id,
    required this.tournamentId,
    this.team1Id,
    this.team2Id,
    this.team1Name,
    this.team2Name,
    this.team1Score = 0,
    this.team2Score = 0,
    this.winnerId,
    this.loserId,
    required this.matchType,
    required this.round,
    required this.position,
    required this.status,
    this.scheduledTime,
    required this.venue,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'tournamentId': tournamentId,
      'team1Id': team1Id,
      'team2Id': team2Id,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'winnerId': winnerId,
      'loserId': loserId,
      'matchType': matchType.toString(),
      'round': round,
      'position': position,
      'status': status,
      'scheduledTime': scheduledTime,
      'venue': venue,
      'metadata': metadata,
    };
  }

  static TournamentMatch fromMap(String id, Map<String, dynamic> map) {
    return TournamentMatch(
      id: id,
      tournamentId: map['tournamentId'] ?? '',
      team1Id: map['team1Id'],
      team2Id: map['team2Id'],
      team1Name: map['team1Name'],
      team2Name: map['team2Name'],
      team1Score: map['team1Score'] ?? 0,
      team2Score: map['team2Score'] ?? 0,
      winnerId: map['winnerId'],
      loserId: map['loserId'],
      matchType: MatchType.values.firstWhere(
        (e) => e.toString() == map['matchType'],
        orElse: () => MatchType.groupStage,
      ),
      round: map['round'] ?? 0,
      position: map['position'] ?? 0,
      status: map['status'] ?? 'Scheduled',
      scheduledTime: map['scheduledTime'] != null 
        ? (map['scheduledTime'] as Timestamp).toDate() 
        : null,
      venue: map['venue'] ?? '',
      metadata: map['metadata'] ?? {},
    );
  }
}
