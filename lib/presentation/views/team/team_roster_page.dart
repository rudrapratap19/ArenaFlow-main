import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/routing/app_router.dart';
import '../../../data/models/team/team_model.dart';
import '../../../data/models/team/player_model.dart';
import '../../blocs/team/team_bloc.dart';

class TeamRosterPage extends StatefulWidget {
  final TeamModel team;

  const TeamRosterPage({super.key, required this.team});

  @override
  State<TeamRosterPage> createState() => _TeamRosterPageState();
}

class _TeamRosterPageState extends State<TeamRosterPage> {
  @override
  void initState() {
    super.initState();
    context.read<TeamBloc>().add(PlayerLoadRequested(teamId: widget.team.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeamBloc, TeamState>(
      listener: (context, state) {
        if (state is TeamOperationSuccess) {
          Helpers.showSnackBar(context, state.message);
          // Reload players after successful operation
          context.read<TeamBloc>().add(PlayerLoadRequested(teamId: widget.team.id));
        }
        if (state is TeamError) {
          Helpers.showSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.team.name),
          backgroundColor: Colors.blue, // Changed from transparent
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  AppRouter.addTeam,
                  arguments: widget.team,
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.pushNamed(
              context,
              AppRouter.addPlayer,
              arguments: widget.team.id,
            );
            // Reload players if player was added
            if (result == true && mounted) {
              context.read<TeamBloc>().add(PlayerLoadRequested(teamId: widget.team.id));
            }
          },
          backgroundColor: Helpers.getSportColor(widget.team.sport),
          icon: const Icon(Icons.person_add),
          label: const Text('Add Player'),
        ),
      body: Column(
        children: [
          // Team header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Helpers.getSportGradient(widget.team.sport),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Helpers.getSportIcon(widget.team.sport),
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 15),
                Text(
                  widget.team.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<TeamBloc, TeamState>(
                  builder: (context, state) {
                    int playerCount = widget.team.playerCount;
                    if (state is PlayersLoaded) {
                      playerCount = state.players.length;
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          '$playerCount Players',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Players list
          Expanded(
            child: BlocBuilder<TeamBloc, TeamState>(
              builder: (context, state) {
                if (state is TeamLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Helpers.getSportColor(widget.team.sport),
                    ),
                  );
                } else if (state is PlayersLoaded) {
                  if (state.players.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_add,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No players in roster',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Tap the + button to add players',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.players.length,
                    itemBuilder: (context, index) {
                      final player = state.players[index];
                      return _buildPlayerCard(player);
                    },
                  );
                } else if (state is TeamError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildPlayerCard(PlayerModel player) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.playerProfile,
            arguments: player,
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              // Jersey number
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Helpers.getSportGradient(widget.team.sport),
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    player.jerseyNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Player info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.sports,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 5),
                        Text(
                          player.position ?? 'N/A',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Icon(
                          Icons.cake,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${player.age} yrs',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action menu
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRouter.addPlayer,
                      arguments: {'teamId': widget.team.id, 'player': player},
                    );
                    // Reload players if player was updated
                    if (result == true && mounted) {
                      context.read<TeamBloc>().add(PlayerLoadRequested(teamId: widget.team.id));
                    }
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, player);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PlayerModel player) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text(
            'Are you sure you want to remove ${player.name} from the roster?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TeamBloc>().add(PlayerDeleteRequested(
                    playerId: player.id,
                    teamId: widget.team.id,
                  ));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
