part of 'tournament_bloc.dart';

abstract class TournamentState extends Equatable {
  const TournamentState();

  @override
  List<Object?> get props => [];
}

class TournamentInitial extends TournamentState {}

class TournamentLoading extends TournamentState {}

class TournamentsLoaded extends TournamentState {
  final List<TournamentModel> tournaments;

  const TournamentsLoaded({required this.tournaments});

  @override
  List<Object?> get props => [tournaments];
}

class TournamentDetailLoaded extends TournamentState {
  final TournamentModel tournament;
  final List<MatchModel> matches;

  const TournamentDetailLoaded({
    required this.tournament,
    required this.matches,
  });

  @override
  List<Object?> get props => [tournament, matches];
}

class TournamentOperationSuccess extends TournamentState {
  final String message;

  const TournamentOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class TournamentError extends TournamentState {
  final String message;

  const TournamentError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TournamentStandingsLoaded extends TournamentState {
  final List<Map<String, dynamic>> standings;

  const TournamentStandingsLoaded({required this.standings});

  @override
  List<Object?> get props => [standings];
}
