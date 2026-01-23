import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/tournament/tournament_model.dart';
import '../../../data/models/match/match_model.dart';
import '../../../data/repositories/tournament/tournament_repository.dart';

part 'tournament_event.dart';
part 'tournament_state.dart';

class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final TournamentRepository _tournamentRepository;

  TournamentBloc({required TournamentRepository tournamentRepository})
      : _tournamentRepository = tournamentRepository,
        super(TournamentInitial()) {
    on<TournamentLoadAllRequested>(_onTournamentLoadAllRequested);
    on<TournamentLoadRequested>(_onTournamentLoadRequested);
    on<TournamentCreateRequested>(_onTournamentCreateRequested);
    on<TournamentUpdateRequested>(_onTournamentUpdateRequested);
    on<TournamentDeleteRequested>(_onTournamentDeleteRequested);
    on<TournamentMatchesLoadRequested>(_onTournamentMatchesLoadRequested);
    on<TournamentStandingsLoadRequested>(_onTournamentStandingsLoadRequested);
  }

  Future<void> _onTournamentLoadAllRequested(
    TournamentLoadAllRequested event,
    Emitter<TournamentState> emit,
  ) async {
    emit(TournamentLoading());
    try {
      await emit.forEach(
        _tournamentRepository.getAllTournaments(),
        onData: (tournaments) => TournamentsLoaded(tournaments: tournaments),
        onError: (error, stackTrace) =>
            TournamentError(message: error.toString()),
      );
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }

  Future<void> _onTournamentLoadRequested(
    TournamentLoadRequested event,
    Emitter<TournamentState> emit,
  ) async {
    emit(TournamentLoading());
    try {
      final tournament =
          await _tournamentRepository.getTournament(event.tournamentId);
      if (tournament == null) {
        emit(const TournamentError(message: 'Tournament not found'));
        return;
      }

      await emit.forEach(
        _tournamentRepository.getTournamentMatches(event.tournamentId),
        onData: (matches) => TournamentDetailLoaded(
          tournament: tournament,
          matches: matches,
        ),
        onError: (error, stackTrace) =>
            TournamentError(message: error.toString()),
      );
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }

  Future<void> _onTournamentCreateRequested(
    TournamentCreateRequested event,
    Emitter<TournamentState> emit,
  ) async {
    try {
      final tournamentId =
          await _tournamentRepository.createTournament(event.tournament);

      if (event.generateBracket) {
        await _tournamentRepository.generateBracket(
          tournamentId,
          event.tournament.type,
          event.tournament.teamIds,
        );
      }

      emit(const TournamentOperationSuccess(
          message: 'Tournament created successfully'));
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }

  Future<void> _onTournamentUpdateRequested(
    TournamentUpdateRequested event,
    Emitter<TournamentState> emit,
  ) async {
    try {
      await _tournamentRepository.updateTournament(event.tournament);
      emit(const TournamentOperationSuccess(
          message: 'Tournament updated successfully'));
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }

  Future<void> _onTournamentDeleteRequested(
    TournamentDeleteRequested event,
    Emitter<TournamentState> emit,
  ) async {
    try {
      await _tournamentRepository.deleteTournament(event.tournamentId);
      emit(const TournamentOperationSuccess(
          message: 'Tournament deleted successfully'));
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }

  Future<void> _onTournamentMatchesLoadRequested(
    TournamentMatchesLoadRequested event,
    Emitter<TournamentState> emit,
  ) async {
    emit(TournamentLoading());
    try {
      await emit.forEach(
        _tournamentRepository.getTournamentMatches(event.tournamentId),
        onData: (matches) {
          // Need to load tournament too
          return TournamentLoading();
        },
        onError: (error, stackTrace) =>
            TournamentError(message: error.toString()),
      );
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }

  Future<void> _onTournamentStandingsLoadRequested(
    TournamentStandingsLoadRequested event,
    Emitter<TournamentState> emit,
  ) async {
    emit(TournamentLoading());
    try {
      final standings =
          await _tournamentRepository.getStandings(event.tournamentId);
      emit(TournamentStandingsLoaded(standings: standings));
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }
}
