import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/match/match_model.dart';
import '../../blocs/match/match_bloc.dart';
import '../../blocs/match/match_event.dart';
import '../../blocs/match/match_state.dart';
import 'match_details_page.dart';

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
      appBar: CustomAppBar(
        title: 'Matches',
        leading: const Icon(Icons.arrow_back_ios_rounded),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'All', icon: Icon(Icons.list_rounded)),
                Tab(text: 'Live', icon: Icon(Icons.play_circle_rounded)),
                Tab(text: 'Scheduled', icon: Icon(Icons.schedule_rounded)),
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMatchesList(),
                _buildMatchesList(),
                _buildMatchesList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.matchMaking);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Match'),
      ),
    );
  }

  Widget _buildMatchesList() {
    return BlocBuilder<MatchBloc, MatchState>(
      builder: (context, state) {
        if (state is MatchLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading matches...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        } else if (state is MatchesLoaded) {
          if (state.matches.isEmpty) {
            return EmptyState(
              icon: Icons.event_busy,
              title: 'No Matches Found',
              subtitle: 'There are no matches at this time. Create a new match to get started.',
              actionLabel: 'Create Match',
              onActionPressed: () {
                Navigator.pushNamed(context, AppRouter.matchMaking);
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final currentTab = _tabController.index;
              if (currentTab == 0) {
                context.read<MatchBloc>().add(MatchLoadAllRequested());
              } else if (currentTab == 1) {
                context.read<MatchBloc>().add(MatchLoadLiveRequested());
              } else {
                context.read<MatchBloc>().add(MatchLoadScheduledRequested());
              }
              await Future.delayed(const Duration(seconds: 1));
            },
            color: AppColors.primary,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[50]!,
                    Colors.white,
                  ],
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: state.matches.length,
                itemBuilder: (context, index) {
                  final match = state.matches[index];
                  return _buildMatchCard(match);
                },
              ),
            ),
          );
        } else if (state is MatchError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Unable to Load Matches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please check your internet connection and try again.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      final currentTab = _tabController.index;
                      if (currentTab == 0) {
                        context.read<MatchBloc>().add(MatchLoadAllRequested());
                      } else if (currentTab == 1) {
                        context.read<MatchBloc>().add(MatchLoadLiveRequested());
                      } else {
                        context.read<MatchBloc>().add(MatchLoadScheduledRequested());
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    final sportColor = Helpers.getSportColor(match.sport);
    final isLive = match.status.toLowerCase() == 'live';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            sportColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: sportColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailsPage(match: match),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sportColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sport Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [sportColor, sportColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: sportColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Helpers.getSportIcon(match.sport),
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            match.sport.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status and Menu
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isLive 
                                ? AppColors.liveGreen 
                                : match.status.toLowerCase() == 'completed'
                                    ? Colors.grey
                                    : AppColors.scheduledOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLive)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (isLive) const SizedBox(width: 6),
                              Text(
                                match.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MatchDetailsPage(match: match),
                                ),
                              );
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(match);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text('Edit Match'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                          icon: Icon(Icons.more_vert_rounded, size: 22, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Teams Row
                Row(
                  children: [
                    // Team 1
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  sportColor.withOpacity(0.15),
                                  sportColor.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: sportColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                Helpers.getInitials(match.team1Name),
                                style: TextStyle(
                                  color: sportColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            match.team1Name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: match.winnerId == match.team1Id 
                                  ? AppColors.success.withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: match.winnerId == match.team1Id
                                    ? AppColors.success
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              match.team1Score.toString(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: match.winnerId == match.team1Id
                                    ? AppColors.success
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // VS Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: sportColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sportColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              'VS',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: sportColor,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Team 2
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  sportColor.withOpacity(0.15),
                                  sportColor.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: sportColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                Helpers.getInitials(match.team2Name),
                                style: TextStyle(
                                  color: sportColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            match.team2Name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: match.winnerId == match.team2Id 
                                  ? AppColors.success.withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: match.winnerId == match.team2Id
                                    ? AppColors.success
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              match.team2Score.toString(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: match.winnerId == match.team2Id
                                    ? AppColors.success
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Divider
                Divider(color: Colors.grey[300], thickness: 1),
                
                const SizedBox(height: 12),
                
                // Match Info Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: sportColor,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              Helpers.formatDateTime(match.scheduledTime),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (match.venue.isNotEmpty) ...[
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: sportColor,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                match.venue,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(MatchModel match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match'),
        content: Text('Delete match between ${match.team1Name} and ${match.team2Name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MatchBloc>().add(MatchDeleteRequested(matchId: match.id));
              Helpers.showSnackBar(context, 'Match deleted successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
