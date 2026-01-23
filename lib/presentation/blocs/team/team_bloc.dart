import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/team/team_model.dart';
import '../../../data/models/team/player_model.dart';
import '../../../data/repositories/team/team_repository.dart';

part 'team_event.dart';
part 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final TeamRepository _teamRepository;

  TeamBloc({required TeamRepository teamRepository})
      : _teamRepository = teamRepository,
        super(TeamInitial()) {
    on<TeamLoadRequested>(_onTeamLoadRequested);
    on<TeamCreateRequested>(_onTeamCreateRequested);
    on<TeamUpdateRequested>(_onTeamUpdateRequested);
    on<TeamDeleteRequested>(_onTeamDeleteRequested);
    on<PlayerLoadRequested>(_onPlayerLoadRequested);
    on<PlayerAddRequested>(_onPlayerAddRequested);
    on<PlayerUpdateRequested>(_onPlayerUpdateRequested);
    on<PlayerDeleteRequested>(_onPlayerDeleteRequested);
  }

  Future<void> _onTeamLoadRequested(
    TeamLoadRequested event,
    Emitter<TeamState> emit,
  ) async {
    emit(TeamLoading());
    try {
      await emit.forEach(
        _teamRepository.getTeamsBySport(event.sport),
        onData: (teams) => TeamLoaded(teams: teams),
        onError: (error, stackTrace) => TeamError(message: error.toString()),
      );
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }

  Future<void> _onTeamCreateRequested(
    TeamCreateRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      await _teamRepository.createTeam(event.team);
      emit(const TeamOperationSuccess(message: 'Team created successfully'));
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }

  Future<void> _onTeamUpdateRequested(
    TeamUpdateRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      await _teamRepository.updateTeam(event.team);
      emit(const TeamOperationSuccess(message: 'Team updated successfully'));
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }

  Future<void> _onTeamDeleteRequested(
    TeamDeleteRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      await _teamRepository.deleteTeam(event.teamId);
      emit(const TeamOperationSuccess(message: 'Team deleted successfully'));
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }

  Future<void> _onPlayerLoadRequested(
    PlayerLoadRequested event,
    Emitter<TeamState> emit,
  ) async {
    emit(TeamLoading());
    try {
      await emit.forEach(
        _teamRepository.getTeamPlayers(event.teamId),
        onData: (players) => PlayersLoaded(players: players),
        onError: (error, stackTrace) => TeamError(message: error.toString()),
      );
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }

  Future<void> _onPlayerAddRequested(
    PlayerAddRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      await _teamRepository.addPlayer(event.player);
      emit(const TeamOperationSuccess(message: 'Player added successfully'));
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }

  Future<void> _onPlayerUpdateRequested(
    PlayerUpdateRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      await _teamRepository.updatePlayer(event.player);
      emit(const TeamOperationSuccess(message: 'Player updated successfully'));
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }

  Future<void> _onPlayerDeleteRequested(
    PlayerDeleteRequested event,
    Emitter<TeamState> emit,
  ) async {
    try {
      await _teamRepository.deletePlayer(event.playerId, event.teamId);
      emit(const TeamOperationSuccess(message: 'Player deleted successfully'));
    } catch (e) {
      emit(TeamError(message: e.toString()));
    }
  }
}
