import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TeamModel extends Equatable {
  final String id;
  final String name;
  final String sport;
  final DateTime createdAt;
  final int playerCount;

  const TeamModel({
    required this.id,
    required this.name,
    required this.sport,
    required this.createdAt,
    this.playerCount = 0,
  });

  factory TeamModel.fromMap(String id, Map<String, dynamic> map) {
    return TeamModel(
      id: id,
      name: map['name'] ?? '',
      sport: map['sport'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      playerCount: map['playerCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sport': sport,
      'createdAt': Timestamp.fromDate(createdAt),
      'playerCount': playerCount,
    };
  }

  TeamModel copyWith({
    String? id,
    String? name,
    String? sport,
    DateTime? createdAt,
    int? playerCount,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sport: sport ?? this.sport,
      createdAt: createdAt ?? this.createdAt,
      playerCount: playerCount ?? this.playerCount,
    );
  }

  @override
  List<Object?> get props => [id, name, sport, createdAt, playerCount];
}
