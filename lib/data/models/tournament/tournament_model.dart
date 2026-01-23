import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

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

class TournamentModel extends Equatable {
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

  const TournamentModel({
    required this.id,
    required this.name,
    required this.sport,
    required this.type,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.teamIds,
    this.settings = const {},
    required this.createdAt,
    required this.createdBy,
  });

  factory TournamentModel.fromMap(String id, Map<String, dynamic> map) {
    return TournamentModel(
      id: id,
      name: map['name'] ?? '',
      sport: map['sport'] ?? '',
      type: _parseTournamentType(map['type']),
      status: _parseTournamentStatus(map['status']),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      teamIds: List<String>.from(map['teamIds'] ?? []),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  static TournamentType _parseTournamentType(dynamic value) {
    if (value == null) return TournamentType.singleElimination;
    if (value is TournamentType) return value;
    final str = value.toString();
    return TournamentType.values.firstWhere(
      (e) => e.toString() == str || e.toString().split('.').last == str,
      orElse: () => TournamentType.singleElimination,
    );
  }

  static TournamentStatus _parseTournamentStatus(dynamic value) {
    if (value == null) return TournamentStatus.registration;
    if (value is TournamentStatus) return value;
    final str = value.toString();
    return TournamentStatus.values.firstWhere(
      (e) => e.toString() == str || e.toString().split('.').last == str,
      orElse: () => TournamentStatus.registration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sport': sport,
      'type': type.toString(),
      'status': status.toString(),
      'startDate': Timestamp.fromDate(startDate),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'teamIds': teamIds,
      'settings': settings,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  TournamentModel copyWith({
    String? id,
    String? name,
    String? sport,
    TournamentType? type,
    TournamentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? teamIds,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return TournamentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sport: sport ?? this.sport,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      teamIds: teamIds ?? this.teamIds,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sport,
        type,
        status,
        startDate,
        endDate,
        teamIds,
        settings,
        createdAt,
        createdBy,
      ];
}
