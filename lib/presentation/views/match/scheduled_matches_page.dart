import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/match/match_model.dart';
import '../../blocs/match/match_bloc.dart';
import '../../blocs/match/match_event.dart';
import '../../blocs/match/match_state.dart';

class ScheduledMatchesPage extends StatefulWidget {
  const ScheduledMatchesPage({super.key});

  @override
  State<ScheduledMatchesPage> createState() => _ScheduledMatchesPageState();
}

class _ScheduledMatchesPageState extends State<ScheduledMatchesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<MatchBloc>().add(MatchLoadAllRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white, // Makes icons/text visible
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Tab text color when selected
          unselectedLabelColor: Colors.white70, // Tab text when unselected
          indicatorColor: Colors.white, // Underline color
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Live', icon: Icon(Icons.play_circle)),
            Tab(text: 'Scheduled', icon: Icon(Icons.schedule)),
          ],
          onTap: (index) {
            if (index == 0) {
              context.read<MatchBloc>().add(MatchLoadAllRequested());
            } else if (index == 1) {
              context.read<MatchBloc>().add(MatchLoadLiveRequested());
            } else {
              context.read<MatchBloc>().add(MatchLoadScheduledRequested());
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMatchesList(),
          _buildMatchesList(),
          _buildMatchesList(),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    return BlocBuilder<MatchBloc, MatchState>(
      builder: (context, state) {
        if (state is MatchLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        } else if (state is MatchesLoaded) {
          if (state.matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No matches found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Fixed: Use correct event name based on current tab
              final currentTab = _tabController.index;
              if (currentTab == 0) {
                context.read<MatchBloc>().add(MatchLoadAllRequested());
              } else if (currentTab == 1) {
                context.read<MatchBloc>().add(MatchLoadLiveRequested());
              } else {
                context.read<MatchBloc>().add(MatchLoadScheduledRequested());
              }
              await Future.delayed(Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.matches.length,
              itemBuilder: (context, index) {
                final match = state.matches[index];
                return _buildMatchCard(match);
              },
            ),
          );
        } else if (state is MatchError) {
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
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    Color statusColor = Helpers.getStatusColor(match.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to match details
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Helpers.getSportIcon(match.sport),
                        size: 20,
                        color: Helpers.getSportColor(match.sport),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        match.sport.toUpperCase(),
                        style: TextStyle(
                          color: Helpers.getSportColor(match.sport),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      match.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Teams and scores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Team 1
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: Helpers.getSportGradient(match.sport),
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              Helpers.getInitials(match.team1Name),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.team1Name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          match.team1Score?.toString() ?? '-',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: match.winnerId == match.team1Id
                                ? Colors.green
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // VS
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'VS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // Team 2
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: Helpers.getSportGradient(match.sport),
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              Helpers.getInitials(match.team2Name),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.team2Name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          match.team2Score?.toString() ?? '-',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: match.winnerId == match.team2Id
                                ? Colors.green
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Match info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(
                    Helpers.formatDateTime(match.scheduledTime),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (match.venue.isNotEmpty) ...[
                    const SizedBox(width: 15),
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(
                      match.venue,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
