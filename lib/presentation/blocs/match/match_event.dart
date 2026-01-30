import 'package:equatable/equatable.dart';
import '../../../data/models/match/match_model.dart';

abstract class MatchEvent extends Equatable {
  const MatchEvent();

  @override
  List<Object?> get props => [];
}

class MatchLoadAllRequested extends MatchEvent {
  const MatchLoadAllRequested();
}

class MatchLoadLiveRequested extends MatchEvent {
  const MatchLoadLiveRequested();
}

class MatchLoadScheduledRequested extends MatchEvent {
  const MatchLoadScheduledRequested();
}

class MatchLoadByIdRequested extends MatchEvent {
  final String matchId;

  const MatchLoadByIdRequested({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}

class MatchCreateRequested extends MatchEvent {
  final MatchModel match;

  const MatchCreateRequested({required this.match});

  @override
  List<Object?> get props => [match];
}

class MatchUpdateRequested extends MatchEvent {
  final MatchModel match;

  const MatchUpdateRequested({required this.match});

  @override
  List<Object?> get props => [match];
}

class MatchScoreUpdateRequested extends MatchEvent {
  final String matchId;
  final int team1Score;
  final int team2Score;

  const MatchScoreUpdateRequested({
    required this.matchId,
    required this.team1Score,
    required this.team2Score,
  });

  @override
  List<Object?> get props => [matchId, team1Score, team2Score];
}

class MatchStatusUpdateRequested extends MatchEvent {
  final String matchId;
  final String status;

  const MatchStatusUpdateRequested({
    required this.matchId,
    required this.status,
  });

  @override
  List<Object?> get props => [matchId, status];
}

class MatchDeleteRequested extends MatchEvent {
  final String matchId;

  const MatchDeleteRequested({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}
class CommentaryAddRequested extends MatchEvent {
  final String matchId;
  final Commentary commentary;

  const CommentaryAddRequested({
    required this.matchId,
    required this.commentary,
  });

  @override
  List<Object?> get props => [matchId, commentary];
}

class PlayerStatUpdateRequested extends MatchEvent {
  final String matchId;
  final PlayerStat playerStat;

  const PlayerStatUpdateRequested({
    required this.matchId,
    required this.playerStat,
  });

  @override
  List<Object?> get props => [matchId, playerStat];
}