part of 'tournament_bloc.dart';

abstract class TournamentEvent extends Equatable {
  const TournamentEvent();

  @override
  List<Object?> get props => [];
}

class TournamentLoadAllRequested extends TournamentEvent {}

class TournamentLoadRequested extends TournamentEvent {
  final String tournamentId;

  const TournamentLoadRequested({required this.tournamentId});

  @override
  List<Object?> get props => [tournamentId];
}

class TournamentCreateRequested extends TournamentEvent {
  final TournamentModel tournament;
  final bool generateBracket;

  const TournamentCreateRequested({
    required this.tournament,
    this.generateBracket = true,
  });

  @override
  List<Object?> get props => [tournament, generateBracket];
}

class TournamentUpdateRequested extends TournamentEvent {
  final TournamentModel tournament;

  const TournamentUpdateRequested({required this.tournament});

  @override
  List<Object?> get props => [tournament];
}

class TournamentDeleteRequested extends TournamentEvent {
  final String tournamentId;

  const TournamentDeleteRequested({required this.tournamentId});

  @override
  List<Object?> get props => [tournamentId];
}

class TournamentMatchesLoadRequested extends TournamentEvent {
  final String tournamentId;

  const TournamentMatchesLoadRequested({required this.tournamentId});

  @override
  List<Object?> get props => [tournamentId];
}

class TournamentStandingsLoadRequested extends TournamentEvent {
  final String tournamentId;

  const TournamentStandingsLoadRequested({required this.tournamentId});

  @override
  List<Object?> get props => [tournamentId];
}
