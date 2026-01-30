import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../blocs/team/team_bloc.dart';

class TeamsListPage extends StatefulWidget {
  final String? initialSport;
  
  const TeamsListPage({super.key, this.initialSport});

  @override
  State<TeamsListPage> createState() => _TeamsListPageState();
}

class _TeamsListPageState extends State<TeamsListPage>
    with TickerProviderStateMixin {
  late String _selectedSport;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize sport from widget parameter or default to football
    _selectedSport = widget.initialSport ?? AppConstants.sportFootball;
    // Always load teams for the selected sport
    // The stream will maintain the data connection
    context
        .read<TeamBloc>()
        .add(TeamLoadRequested(sport: _selectedSport));

    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.defaultAnimationDuration,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeSport(String sport) {
    setState(() {
      _selectedSport = sport;
    });
    context.read<TeamBloc>().add(TeamLoadRequested(sport: sport));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Teams',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addTeam);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Team'),
      ),
      body: Column(
        children: [
          // Sport selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  AppConstants.sportFootball,
                  AppConstants.sportCricket,
                  AppConstants.sportBasketball,
                  AppConstants.sportVolleyball,
                ].map((sport) {
                  final isSelected = sport == _selectedSport;
                  final sportColor = Helpers.getSportColor(sport);
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => _changeSport(sport),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? sportColor
                              : sportColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : sportColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Helpers.getSportIcon(sport),
                              size: 20,
                              color: isSelected ? AppColors.textWhite : sportColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              sport,
                              style: TextStyle(
                                color: isSelected ? AppColors.textWhite : sportColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Teams list
          Expanded(
            child: BlocBuilder<TeamBloc, TeamState>(
              builder: (context, state) {
                if (state is TeamLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is TeamLoaded) {
                  if (state.teams.isEmpty) {
                    return EmptyState(
                      icon: Helpers.getSportIcon(_selectedSport),
                      title: 'No $_selectedSport Teams',
                      subtitle: 'Create your first team to get started. Tap the + button below.',
                      iconColor: Helpers.getSportColor(_selectedSport),
                      actionLabel: 'Add Team',
                      onActionPressed: () {
                        Navigator.pushNamed(context, AppRouter.addTeam);
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.teams.length,
                    itemBuilder: (context, index) {
                      final team = state.teams[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildTeamCard(team),
                      );
                    },
                  );
                } else if (state is TeamError) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: 'Error Loading Teams',
                    subtitle: state.message,
                    iconColor: AppColors.error,
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(dynamic team) {
    final sportColor = Helpers.getSportColor(team.sport);
    
    return ModernCard(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.teamRoster,
          arguments: team,
        );
      },
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: sportColor.withOpacity(0.1),
              border: Border.all(
                color: sportColor.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Helpers.getSportIcon(team.sport),
              color: sportColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${team.playerCount} players',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, color: AppColors.primary),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, color: AppColors.error),
                    SizedBox(width: 10),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.pushNamed(
                  context,
                  AppRouter.addTeam,
                  arguments: team,
                );
              } else if (value == 'delete') {
                _showDeleteDialog(context, team.id);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String teamId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Team'),
        content:
            const Text('Are you sure you want to delete this team and all its players?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TeamBloc>().add(TeamDeleteRequested(teamId: teamId));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
