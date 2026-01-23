import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/routing/app_router.dart';
import '../../../data/models/tournament/tournament_model.dart';
import '../../blocs/tournament/tournament_bloc.dart';

class TournamentsListPage extends StatefulWidget {
  const TournamentsListPage({super.key});

  @override
  State<TournamentsListPage> createState() => _TournamentsListPageState();
}

class _TournamentsListPageState extends State<TournamentsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<TournamentBloc>().add(TournamentLoadAllRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.createTournament);
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('Create Tournament'),
      ),
      body: BlocBuilder<TournamentBloc, TournamentState>(
        builder: (context, state) {
          if (state is TournamentLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          } else if (state is TournamentsLoaded) {
            if (state.tournaments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No tournaments yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap the + button to create one',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.tournaments.length,
              itemBuilder: (context, index) {
                final tournament = state.tournaments[index];
                return _buildTournamentCard(tournament);
              },
            );
          } else if (state is TournamentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
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
    );
  }

  Widget _buildTournamentCard(TournamentModel tournament) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (tournament.status) {
      case TournamentStatus.registration:
        statusColor = AppColors.scheduledOrange;
        statusText = 'Registration Open';
        statusIcon = Icons.how_to_reg;
        break;
      case TournamentStatus.inProgress:
        statusColor = AppColors.liveGreen;
        statusText = 'In Progress';
        statusIcon = Icons.play_circle_filled;
        break;
      case TournamentStatus.completed:
        statusColor = Colors.grey; // Changed from AppColors.completedGrey
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.tournamentDetails,
            arguments: tournament,
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: Helpers.getSportGradient(tournament.sport)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Sport icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: Helpers.getSportGradient(tournament.sport)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Helpers.getSportIcon(tournament.sport),
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Tournament info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          tournament.type.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Tournament details
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(
                    'Start: ${Helpers.formatDate(tournament.startDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(width: 20),
                  Icon(Icons.groups, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(
                    '${tournament.teamIds.length} Teams',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
