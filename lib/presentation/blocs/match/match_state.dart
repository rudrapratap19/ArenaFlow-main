import 'package:equatable/equatable.dart';
import '../../../data/models/match/match_model.dart';

abstract class MatchState extends Equatable {
  const MatchState();

  @override
  List<Object?> get props => [];
}

class MatchInitial extends MatchState {
  const MatchInitial();
}

class MatchLoading extends MatchState {
  const MatchLoading();
}

class MatchesLoaded extends MatchState {
  final List<MatchModel> matches;

  const MatchesLoaded({required this.matches});

  @override
  List<Object?> get props => [matches];
}

class MatchDetailLoaded extends MatchState {
  final MatchModel match;

  const MatchDetailLoaded({required this.match});

  @override
  List<Object?> get props => [match];
}

class MatchOperationSuccess extends MatchState {
  final String message;

  const MatchOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class MatchError extends MatchState {
  final String message;

  const MatchError({required this.message});

  @override
  List<Object?> get props => [message];
}
