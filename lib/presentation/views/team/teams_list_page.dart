import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/routing/app_router.dart';
import '../../blocs/team/team_bloc.dart';

class TeamsListPage extends StatefulWidget {
  const TeamsListPage({super.key});

  @override
  State<TeamsListPage> createState() => _TeamsListPageState();
}

class _TeamsListPageState extends State<TeamsListPage>
    with TickerProviderStateMixin {
  String _selectedSport = AppConstants.sportFootball;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(
        title: const Text('Teams'),
        backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addTeam);
        },
        backgroundColor: Helpers.getSportColor(_selectedSport),
        icon: const Icon(Icons.add),
        label: const Text('Add Team'),
      ),
      body: Column(
        children: [
          // Sport selector
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                AppConstants.sportFootball,
                AppConstants.sportCricket,
                AppConstants.sportBasketball,
                AppConstants.sportVolleyball,
              ].map((sport) {
                final isSelected = sport == _selectedSport;
                return GestureDetector(
                  onTap: () => _changeSport(sport),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 15),
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: Helpers.getSportGradient(sport) ?? [Colors.grey],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Helpers.getSportColor(sport)
                                    .withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Helpers.getSportIcon(sport),
                          size: 35,
                          color: isSelected
                              ? Colors.white
                              : Helpers.getSportColor(sport),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sport,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Teams list
          Expanded(
            child: BlocBuilder<TeamBloc, TeamState>(
              builder: (context, state) {
                if (state is TeamLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Helpers.getSportColor(_selectedSport),
                    ),
                  );
                } else if (state is TeamLoaded) {
                  if (state.teams.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Helpers.getSportIcon(_selectedSport),
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No teams for $_selectedSport yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tap the + button to add a team',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.teams.length,
                    itemBuilder: (context, index) {
                      final team = state.teams[index];
                      return FadeTransition(
                        opacity: _controller,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.3 * (index + 1)),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeOut,
                          )),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.teamRoster,
                                  arguments: team,
                                );
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: Helpers.getSportGradient(team.sport)
                                        ?.map((color) => color.withOpacity(0.3))
                                        .toList() ?? [Colors.grey],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: Helpers.getSportGradient(team.sport) ?? [Colors.grey],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Helpers.getSportIcon(team.sport),
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            team.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.people,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                '${team.playerCount} players',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton(
                                      icon: const Icon(Icons.more_vert),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit,
                                                  color: Colors.blue),
                                              SizedBox(width: 10),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red),
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
                              ),
                            ),
                          ),
                        ),
                      );
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
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
