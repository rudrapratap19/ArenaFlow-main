import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/match/match_model.dart';
import '../../../data/models/team/player_model.dart';
import '../../../data/repositories/team/team_repository.dart';
import '../../blocs/match/match_bloc.dart';
import '../../blocs/match/match_state.dart';
import '../../blocs/match/match_event.dart';

class UserMatchDetailsPage extends StatefulWidget {
  final MatchModel match;

  const UserMatchDetailsPage({super.key, required this.match});

  @override
  State<UserMatchDetailsPage> createState() => _UserMatchDetailsPageState();
}

class _UserMatchDetailsPageState extends State<UserMatchDetailsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<MatchBloc>().add(MatchLoadByIdRequested(matchId: widget.match.id));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchBloc, MatchState>(
      builder: (context, state) {
        MatchModel match = widget.match;
        
        if (state is MatchDetailLoaded) {
          match = state.match;
        }
        
        final sportColor = Helpers.getSportColor(match.sport);
        final isLive = match.status.toLowerCase() == 'live';

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  match.sport.toUpperCase(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      match.team1Name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    const Text('vs', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      match.team2Name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            backgroundColor: sportColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Score Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        sportColor,
                        sportColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLive ? AppColors.liveGreen : AppColors.scheduledOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLive)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              match.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                match.team1Name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${match.team1Score}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'vs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                match.team2Name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${match.team2Score}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Match Info
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              Helpers.formatDateTime(match.scheduledTime),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            if (match.venue.isNotEmpty) ...[
                              const SizedBox(width: 16),
                              Icon(Icons.location_on, size: 14, color: Colors.white70),
                              const SizedBox(width: 6),
                              Text(
                                match.venue,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tabs
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[700],
                    indicator: BoxDecoration(
                      color: sportColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.sports_score, size: 20),
                        text: 'Stats',
                      ),
                      Tab(
                        icon: Icon(Icons.people, size: 20),
                        text: 'Players',
                      ),
                      Tab(
                        icon: Icon(Icons.comment, size: 20),
                        text: 'Commentary',
                      ),
                    ],
                  ),
                ),

                // Tab Content
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStatsTab(match, sportColor),
                      _buildPlayersTab(match, sportColor),
                      _buildCommentaryTab(match, sportColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab(MatchModel match, Color sportColor) {
    if (match.playerStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_score,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No player stats yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final team1Stats = match.playerStats
        .where((stat) => stat.teamId == match.team1Id)
        .toList();
    final team2Stats = match.playerStats
        .where((stat) => stat.teamId == match.team2Id)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeamStatsSection(
            match.team1Name,
            team1Stats,
            sportColor,
          ),
          const SizedBox(height: 24),
          _buildTeamStatsSection(
            match.team2Name,
            team2Stats,
            sportColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStatsSection(
    String teamName,
    List<PlayerStat> stats,
    Color sportColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: sportColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              teamName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...stats.map((stat) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.playerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatItem('Goals', '${stat.goals}', sportColor),
                    const SizedBox(width: 16),
                    _buildStatItem('Assists', '${stat.assists}', Colors.blue),
                    const SizedBox(width: 16),
                    _buildStatItem('Yellow', '${stat.yellowCards}', Colors.orange),
                    const SizedBox(width: 16),
                    _buildStatItem('Red', '${stat.redCards}', Colors.red),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersTab(MatchModel match, Color sportColor) {
    return StreamBuilder<List<PlayerModel>>(
      stream: context.read<TeamRepository>().getTeamPlayers(match.team1Id),
      builder: (context, team1Snapshot) {
        return StreamBuilder<List<PlayerModel>>(
          stream: context.read<TeamRepository>().getTeamPlayers(match.team2Id),
          builder: (context, team2Snapshot) {
            final team1Players = team1Snapshot.data ?? [];
            final team2Players = team2Snapshot.data ?? [];

            final isLoading = !team1Snapshot.hasData || !team2Snapshot.hasData;

            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeamPlayersSection(
                    match.team1Name,
                    team1Players,
                    sportColor,
                  ),
                  const SizedBox(height: 24),
                  _buildTeamPlayersSection(
                    match.team2Name,
                    team2Players,
                    sportColor,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTeamPlayersSection(
    String teamName,
    List<PlayerModel> players,
    Color sportColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: sportColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              teamName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (players.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No players available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...players.map((player) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: sportColor.withOpacity(0.1),
                    radius: 24,
                    child: Icon(
                      Icons.person,
                      color: sportColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Jersey #${player.jerseyNumber ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildCommentaryTab(MatchModel match, Color sportColor) {
    if (match.commentaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No commentaries yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...match.commentaries.reversed.map((commentary) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: sportColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sportColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: sportColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          commentary.teamName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: sportColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 12,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${commentary.minute}'",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    commentary.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
