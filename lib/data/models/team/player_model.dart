import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PlayerModel extends Equatable {
  final String id;
  final String teamId;
  final String name;
  final String? jerseyNumber;
  final String? position;
  final int? age;
  final String? phone;
  final String? email;
  final String? height;
  final String? weight;
  final String? experience;
  final String? statistics;
  final DateTime createdAt;
  final String createdBy;

  const PlayerModel({
    required this.id,
    required this.teamId,
    required this.name,
    this.jerseyNumber,
    this.position,
    this.age,
    this.phone,
    this.email,
    this.height,
    this.weight,
    this.experience,
    this.statistics,
    required this.createdAt,
    required this.createdBy,
  });

  factory PlayerModel.fromMap(String id, Map<String, dynamic> map) {
    return PlayerModel(
      id: id,
      teamId: map['teamId'] ?? '',
      name: map['name'] ?? '',
      jerseyNumber: map['jerseyNumber']?.toString(),
      position: map['position'],
      age: map['age'],
      phone: map['phone'],
      email: map['email'],
      height: map['height'],
      weight: map['weight'],
      experience: map['experience'],
      statistics: map['statistics'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'name': name,
      if (jerseyNumber != null) 'jerseyNumber': jerseyNumber,
      if (position != null) 'position': position,
      if (age != null) 'age': age,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (experience != null) 'experience': experience,
      if (statistics != null) 'statistics': statistics,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  PlayerModel copyWith({
    String? id,
    String? teamId,
    String? name,
    String? jerseyNumber,
    String? position,
    int? age,
    String? phone,
    String? email,
    String? height,
    String? weight,
    String? experience,
    String? statistics,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      position: position ?? this.position,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      experience: experience ?? this.experience,
      statistics: statistics ?? this.statistics,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        teamId,
        name,
        jerseyNumber,
        position,
        age,
        phone,
        email,
        height,
        weight,
        experience,
        statistics,
        createdAt,
        createdBy,
      ];
}
