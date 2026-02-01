import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/tournament/tournament_model.dart';
import '../../../data/models/match/match_model.dart';
import '../../blocs/tournament/tournament_bloc.dart';

class TournamentDetailsPage extends StatefulWidget {
  final TournamentModel tournament;

  const TournamentDetailsPage({super.key, required this.tournament});

  @override
  State<TournamentDetailsPage> createState() => _TournamentDetailsPageState();
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<TournamentBloc>()
        .add(TournamentLoadRequested(tournamentId: widget.tournament.id));
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Tournament',
            onPressed: () => _confirmDeleteTournament(context, t),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRouter.matchMaking,
          arguments: t,
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Match'),
      ),
      body: BlocConsumer<TournamentBloc, TournamentState>(
        listener: (context, state) {
          if (state is TournamentOperationSuccess && mounted) {
            final message = state.message.toLowerCase();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            if (message.contains('deleted')) {
              Navigator.pop(context, true);
            }
          }
        },
        builder: (context, state) {
          if (state is TournamentLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is TournamentDetailLoaded) {
            if (state.matches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No matches yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Create matches to get started',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildTournamentHeader(t),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final m = state.matches[index];
                        return _buildMatchCard(m);
                      },
                      childCount: state.matches.length,
                    ),
                  ),
                ),
              ],
            );
          }
          if (state is TournamentError) {
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

  Future<void> _confirmDeleteTournament(
    BuildContext context,
    TournamentModel tournament,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Tournament?'),
          content: Text(
            'This will delete "${tournament.name}" and all its matches. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      context
          .read<TournamentBloc>()
          .add(TournamentDeleteRequested(tournamentId: tournament.id));
    }
  }

  Widget _buildTournamentHeader(TournamentModel t) {
    // Format tournament type with spaces
    String formattedType = t.type
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .toUpperCase();
    
    final statusColor = _getStatusColor(t.status.toString().split('.').last);
    final statusText = _getStatusText(t.status);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formattedType,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  icon: Icons.calendar_today,
                  label: 'Start Date',
                  value: Helpers.formatDate(t.startDate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderStat(
                  icon: Icons.groups,
                  label: 'Teams',
                  value: '${t.teamIds.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchModel m) {
    final statusColor = _getStatusColor(m.status);
    final isLive = m.status == 'In Progress';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.12),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            AppRouter.matchDetails,
            arguments: m,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header with type and status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.matchType?.toString().split('.').last.toUpperCase() ?? 'MATCH',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                Helpers.formatDateTime(m.scheduledTime),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        m.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Divider
                Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 18),
                // Match teams and scores
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            m.team1Name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${m.team1Score}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          if (isLive) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.liveGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.liveGreen,
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            m.team2Name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${m.team2Score}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
      case 'inprogress':
        return AppColors.liveGreen;
      case 'scheduled':
        return AppColors.scheduledOrange;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getStatusText(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.registration:
        return 'Registration Open';
      case TournamentStatus.inProgress:
        return 'In Progress';
      case TournamentStatus.completed:
        return 'Completed';
    }
  }
}
