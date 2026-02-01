import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/match/match_model.dart';
import '../../../data/models/tournament/tournament_model.dart';
import '../../../data/repositories/match/match_repository.dart';
import '../match/match_details_page.dart';
import '../match/user_match_details_page.dart';

class TournamentMatchesPage extends StatefulWidget {
  final TournamentModel tournament;
  final String adminName;
  final bool isReadOnly;

  const TournamentMatchesPage({
    super.key,
    required this.tournament,
    required this.adminName,
    this.isReadOnly = true,
  });

  @override
  State<TournamentMatchesPage> createState() => _TournamentMatchesPageState();
}

class _TournamentMatchesPageState extends State<TournamentMatchesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchRepository = context.read<MatchRepository>();
    final sportColor = Helpers.getSportColor(widget.tournament.sport);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.tournament.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.adminName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: sportColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: sportColor,
          child: Column(
            children: [
              _buildTournamentHeader(sportColor),
              if (widget.isReadOnly)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'View Only Mode - You are viewing ${widget.adminName}\'s tournament',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildTabBar(sportColor),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMatchesList(
                      matchRepository.getTournamentMatches(
                        widget.tournament.id,
                      ),
                      sportColor,
                    ),
                    _buildMatchesList(
                      matchRepository
                          .getTournamentMatches(widget.tournament.id)
                          .map(
                            (matches) => matches
                                .where((m) => m.status.toLowerCase() == 'live')
                                .toList(),
                          ),
                      sportColor,
                    ),
                    _buildMatchesList(
                      matchRepository
                          .getTournamentMatches(widget.tournament.id)
                          .map(
                            (matches) => matches
                                .where(
                                  (m) => m.status.toLowerCase() == 'scheduled',
                                )
                                .toList(),
                          ),
                      sportColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentHeader(Color sportColor) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [sportColor, sportColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: sportColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Helpers.getSportIcon(widget.tournament.sport),
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tournament.sport.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.tournament.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color sportColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: sportColor,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: sportColor,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Live'),
          Tab(text: 'Scheduled'),
        ],
      ),
    );
  }

  Widget _buildMatchesList(Stream<List<MatchModel>> stream, Color sportColor) {
    return StreamBuilder<List<MatchModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: sportColor));
        }
        final matches = snapshot.data ?? [];
        if (matches.isEmpty) {
          return _buildEmptyState(sportColor);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: matches.length,
          itemBuilder: (context, index) =>
              _buildMatchCard(matches[index], sportColor),
        );
      },
    );
  }

  Widget _buildEmptyState(Color sportColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: sportColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sports_soccer_outlined,
              size: 64,
              color: sportColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Matches Found',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Matches will appear here once scheduled',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match, Color sportColor) {
    final isLive = match.status.toLowerCase() == 'live';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            isLive
                ? AppColors.liveGreen.withOpacity(0.03)
                : sportColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLive
              ? AppColors.liveGreen.withOpacity(0.4)
              : sportColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isLive
                ? AppColors.liveGreen.withOpacity(0.15)
                : sportColor.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: widget.isReadOnly
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserMatchDetailsPage(match: match),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: _buildMatchCardContent(match, sportColor, isLive),
                ),
              ),
            )
          : Material(
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
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: _buildMatchCardContent(match, sportColor, isLive),
                ),
              ),
            ),
    );
  }

  Widget _buildMatchCardContent(
    MatchModel match,
    Color sportColor,
    bool isLive,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [sportColor, sportColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                match.sport.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLive ? AppColors.liveGreen : AppColors.scheduledOrange,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isLive
                                ? AppColors.liveGreen
                                : AppColors.scheduledOrange)
                            .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    match.team1Name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    match.team1Score.toString(),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: match.winnerId == match.team1Id
                          ? sportColor
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'VS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    match.team2Name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    match.team2Score.toString(),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: match.winnerId == match.team2Id
                          ? sportColor
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.grey[300], height: 1),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: sportColor),
              const SizedBox(width: 6),
              Text(
                Helpers.formatDateTime(match.scheduledTime),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (match.venue.isNotEmpty) ...[
                const SizedBox(width: 16),
                Icon(Icons.location_on_outlined, size: 14, color: sportColor),
                const SizedBox(width: 6),
                Text(
                  match.venue,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        // Commentary Section for Live Matches
        if (match.commentaries.isNotEmpty) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300], height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.comment_outlined, size: 16, color: sportColor),
              const SizedBox(width: 8),
              Text(
                'Live Commentary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: sportColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: match.commentaries.length > 5 ? 5 : match.commentaries.length,
              itemBuilder: (context, index) {
                final commentaries = match.commentaries.reversed.toList();
                final commentary = commentaries[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: sportColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sportColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sportColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${commentary.minute}'",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              commentary.teamName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: sportColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              commentary.message,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
