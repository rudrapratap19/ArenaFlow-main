import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MatchType {
  groupStage,
  roundOf16,
  quarterFinal,
  semiFinal,
  final_,
  thirdPlace,
  winnerBracket,
  loserBracket,
  grandFinal,
}

class MatchModel extends Equatable {
  final String id;
  final String? tournamentId;
  final String team1Id;
  final String team2Id;
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final String? winnerId;
  final String? loserId;
  final String sport;
  final String venue;
  final DateTime scheduledTime;
  final String status;
  final MatchType? matchType;
  final int? round;
  final int? position;
  final DateTime createdAt;

  const MatchModel({
    required this.id,
    this.tournamentId,
    required this.team1Id,
    required this.team2Id,
    required this.team1Name,
    required this.team2Name,
    this.team1Score = 0,
    this.team2Score = 0,
    this.winnerId,
    this.loserId,
    required this.sport,
    required this.venue,
    required this.scheduledTime,
    required this.status,
    this.matchType,
    this.round,
    this.position,
    required this.createdAt,
  });

  factory MatchModel.fromMap(String id, Map<String, dynamic> map) {
    return MatchModel(
      id: id,
      tournamentId: map['tournamentId'],
      team1Id: map['team1Id'] ?? map['team1'] ?? '',
      team2Id: map['team2Id'] ?? map['team2'] ?? '',
      team1Name: map['team1Name'] ?? '',
      team2Name: map['team2Name'] ?? '',
      team1Score: map['team1Score'] ?? 0,
      team2Score: map['team2Score'] ?? 0,
      winnerId: map['winnerId'],
      loserId: map['loserId'],
      sport: map['sport'] ?? '',
      venue: map['venue'] ?? '',
      scheduledTime: (map['scheduledTime'] as Timestamp?)?.toDate() ??
          (map['matchTime'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      status: map['status'] ?? 'Scheduled',
      matchType: map['matchType'] != null ? _parseMatchType(map['matchType']) : null,
      round: map['round'],
      position: map['position'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static MatchType _parseMatchType(dynamic value) {
    if (value == null) return MatchType.groupStage;
    if (value is MatchType) return value;
    final str = value.toString();
    return MatchType.values.firstWhere(
      (e) => e.toString() == str || e.toString().split('.').last == str,
      orElse: () => MatchType.groupStage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (tournamentId != null) 'tournamentId': tournamentId,
      'team1Id': team1Id,
      'team2Id': team2Id,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'team1Score': team1Score,
      'team2Score': team2Score,
      if (winnerId != null) 'winnerId': winnerId,
      if (loserId != null) 'loserId': loserId,
      'sport': sport,
      'venue': venue,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'status': status,
      if (matchType != null) 'matchType': matchType.toString(),
      if (round != null) 'round': round,
      if (position != null) 'position': position,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MatchModel copyWith({
    String? id,
    String? tournamentId,
    String? team1Id,
    String? team2Id,
    String? team1Name,
    String? team2Name,
    int? team1Score,
    int? team2Score,
    String? winnerId,
    String? loserId,
    String? sport,
    String? venue,
    DateTime? scheduledTime,
    String? status,
    MatchType? matchType,
    int? round,
    int? position,
    DateTime? createdAt,
  }) {
    return MatchModel(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      team1Id: team1Id ?? this.team1Id,
      team2Id: team2Id ?? this.team2Id,
      team1Name: team1Name ?? this.team1Name,
      team2Name: team2Name ?? this.team2Name,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      winnerId: winnerId ?? this.winnerId,
      loserId: loserId ?? this.loserId,
      sport: sport ?? this.sport,
      venue: venue ?? this.venue,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      matchType: matchType ?? this.matchType,
      round: round ?? this.round,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tournamentId,
        team1Id,
        team2Id,
        team1Name,
        team2Name,
        team1Score,
        team2Score,
        winnerId,
        loserId,
        sport,
        venue,
        scheduledTime,
        status,
        matchType,
        round,
        position,
        createdAt,
      ];
}
