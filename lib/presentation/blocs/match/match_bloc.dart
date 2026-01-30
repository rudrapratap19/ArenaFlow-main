import 'package:flutter_bloc/flutter_bloc.dart';
import 'match_event.dart';
import 'match_state.dart';
import '../../../data/models/match/match_model.dart';
import '../../../data/repositories/match/match_repository.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final MatchRepository _matchRepository;

  MatchBloc({required MatchRepository matchRepository})
      : _matchRepository = matchRepository,
        super(MatchInitial()) {
    on<MatchLoadAllRequested>(_onMatchLoadAllRequested);
    on<MatchLoadLiveRequested>(_onMatchLoadLiveRequested);
    on<MatchLoadScheduledRequested>(_onMatchLoadScheduledRequested);
    on<MatchLoadByIdRequested>(_onMatchLoadByIdRequested);
    on<MatchCreateRequested>(_onMatchCreateRequested);
    on<MatchUpdateRequested>(_onMatchUpdateRequested);
    on<MatchScoreUpdateRequested>(_onMatchScoreUpdateRequested);
    on<MatchStatusUpdateRequested>(_onMatchStatusUpdateRequested);
    on<MatchDeleteRequested>(_onMatchDeleteRequested);
    on<CommentaryAddRequested>(_onCommentaryAddRequested);
    on<PlayerStatUpdateRequested>(_onPlayerStatUpdateRequested);
  }

  Future<void> _onMatchLoadAllRequested(
    MatchLoadAllRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    try {
      await emit.forEach(
        _matchRepository.getAllMatches(),
        onData: (matches) => MatchesLoaded(matches: matches),
        onError: (error, stackTrace) => MatchError(message: error.toString()),
      );
    } catch (e) {
      emit(MatchError(message: e.toString()));
    }
  }

  Future<void> _onMatchLoadLiveRequested(
    MatchLoadLiveRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    try {
      await emit.forEach(
        _matchRepository.getLiveMatches(),
        onData: (matches) => MatchesLoaded(matches: matches),
        onError: (error, stackTrace) => MatchError(message: error.toString()),
      );
    } catch (e) {
      emit(MatchError(message: e.toString()));
    }
  }

  Future<void> _onMatchLoadScheduledRequested(
    MatchLoadScheduledRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    try {
      await emit.forEach(
        _matchRepository.getScheduledMatches(),
        onData: (matches) => MatchesLoaded(matches: matches),
        onError: (error, stackTrace) => MatchError(message: error.toString()),
      );
    } catch (e) {
      emit(MatchError(message: e.toString()));
    }
  }

  Future<void> _onMatchLoadByIdRequested(
    MatchLoadByIdRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    try {
      await emit.forEach(
        _matchRepository.getMatchStream(event.matchId),
        onData: (match) {
          if (match == null) {
            return const MatchError(message: 'Match not found');
          }
          return MatchDetailLoaded(match: match);
        },
        onError: (error, stackTrace) => MatchError(message: error.toString()),
      );
    } catch (e) {
      emit(MatchError(message: e.toString()));
    }
  }

  Future<void> _onMatchCreateRequested(
    MatchCreateRequested event,
    Emitter<MatchState> emit,
  ) async {
    try {
      await _matchRepository.createMatch(event.match);
      emit(const MatchOperationSuccess(message: 'Match created successfully'));
    } catch (e) {
      emit(MatchError(message: e.toString()));
    }
  }

  Future<void> _onMatchUpdateRequested(
    MatchUpdateRequested event,
    Emitter<MatchState> emit,
  ) async {
    try {
      await _matchRepository.updateMatch(event.match);
      emit(const MatchOperationSuccess(message: 'Match updated successfully'));
    } catch (e) {
      emit(MatchError(message: e.toString()));
    }
  }

  Future<void> _onMatchScoreUpdateRequested(
    MatchScoreUpdateRequested event,
    Emitter<MatchState> emit,
  ) async {
    try {
      await _matchRepository.updateMatchScore(
        event.matchId,
        event.team1Score,
        event.team2Score,
      );
      emit(const MatchOperationSuccess(message: 'Score updated successfully'));
    } catch (e) {
      emit(MatchError(message: e.toString()));
    }
  }

  Future<void> _onMatchStatusUpdateRequested(
    MatchStatusUpdateRequested event,
    Emitter<MatchState> emit,
  ) async {
    try {
      await _matchRepository.updateMatchStatus(event.matchId, event.status);
      emit(const MatchOperationSuccess(message: 'Status updated successfully'));
    } catch (e) {
      emit(MatchError(message: e.toString()));
    }
  }

  Future<void> _onMatchDeleteRequested(
    MatchDeleteRequested event,
    Emitter<MatchState> emit,
  ) async {
    try {
      await _matchRepository.deleteMatch(event.matchId);
      emit(const MatchOperationSuccess(message: 'Match deleted successfully'));
    } catch (e) {
      emit(MatchError(message: e.toString()));
    }
  }

  Future<void> _onCommentaryAddRequested(
    CommentaryAddRequested event,
    Emitter<MatchState> emit,
  ) async {
    try {
      await _matchRepository.addCommentary(event.matchId, event.commentary);
      emit(const CommentaryAdded(message: 'Commentary added successfully'));
    } catch (e) {
      emit(MatchError(message: e.toString()));
    }
  }

  Future<void> _onPlayerStatUpdateRequested(
    PlayerStatUpdateRequested event,
    Emitter<MatchState> emit,
  ) async {
    try {
      await _matchRepository.updatePlayerStats(event.matchId, event.playerStat);
      emit(const PlayerStatUpdated(message: 'Player stats updated successfully'));
    } catch (e) {
      emit(MatchError(message: e.toString()));
    }
  }
}
