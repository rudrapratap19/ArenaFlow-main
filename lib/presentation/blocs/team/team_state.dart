part of 'team_bloc.dart';

abstract class TeamState extends Equatable {
  const TeamState();

  @override
  List<Object?> get props => [];
}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class TeamLoaded extends TeamState {
  final List<TeamModel> teams;

  const TeamLoaded({required this.teams});

  @override
  List<Object?> get props => [teams];
}

class TeamOperationSuccess extends TeamState {
  final String message;

  const TeamOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class TeamError extends TeamState {
  final String message;

  const TeamError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PlayersLoaded extends TeamState {
  final List<PlayerModel> players;

  const PlayersLoaded({required this.players});

  @override
  List<Object?> get props => [players];
}
