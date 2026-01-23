part of 'team_bloc.dart';

abstract class TeamEvent extends Equatable {
  const TeamEvent();

  @override
  List<Object?> get props => [];
}

class TeamLoadRequested extends TeamEvent {
  final String sport;

  const TeamLoadRequested({required this.sport});

  @override
  List<Object?> get props => [sport];
}

class TeamCreateRequested extends TeamEvent {
  final TeamModel team;

  const TeamCreateRequested({required this.team});

  @override
  List<Object?> get props => [team];
}

class TeamUpdateRequested extends TeamEvent {
  final TeamModel team;

  const TeamUpdateRequested({required this.team});

  @override
  List<Object?> get props => [team];
}

class TeamDeleteRequested extends TeamEvent {
  final String teamId;

  const TeamDeleteRequested({required this.teamId});

  @override
  List<Object?> get props => [teamId];
}

class PlayerLoadRequested extends TeamEvent {
  final String teamId;

  const PlayerLoadRequested({required this.teamId});

  @override
  List<Object?> get props => [teamId];
}

class PlayerAddRequested extends TeamEvent {
  final PlayerModel player;

  const PlayerAddRequested({required this.player});

  @override
  List<Object?> get props => [player];
}

class PlayerUpdateRequested extends TeamEvent {
  final PlayerModel player;

  const PlayerUpdateRequested({required this.player});

  @override
  List<Object?> get props => [player];
}

class PlayerDeleteRequested extends TeamEvent {
  final String playerId;
  final String teamId;

  const PlayerDeleteRequested({
    required this.playerId,
    required this.teamId,
  });

  @override
  List<Object?> get props => [playerId, teamId];
}
