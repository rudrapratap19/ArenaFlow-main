import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tournament_models.dart';

class BracketViewPage extends StatefulWidget {
  final String tournamentId;
  final TournamentType tournamentType;

  const BracketViewPage({
    super.key,
    required this.tournamentId,
    required this.tournamentType,
  });

  @override
  State<BracketViewPage> createState() => _BracketViewPageState();
}

class _BracketViewPageState extends State<BracketViewPage> 
    with TickerProviderStateMixin {
  List<TournamentMatch> matches = [];
  bool isLoading = true;
  Map<int, List<TournamentMatch>> roundMatches = {};
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bracketController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadMatches();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _bracketController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bracketController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('tournamentMatches')
        .where('tournamentId', isEqualTo: widget.tournamentId)
        .get();

    matches = matchesSnapshot.docs
        .map((doc) => TournamentMatch.fromMap(doc.id, doc.data()))
        .toList();

    // Group matches by round
    roundMatches.clear();
    for (var match in matches) {
      roundMatches[match.round] ??= [];
      roundMatches[match.round]!.add(match);
    }

    // Sort each round by position
    roundMatches.forEach((round, matchList) {
      matchList.sort((a, b) => a.position.compareTo(b.position));
    });

    setState(() => isLoading = false);
    
    // Start animations after loading
    _fadeController.forward();
    _slideController.forward();
    _bracketController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 2 * 3.14159,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.white70],
                          ),
                        ),
                        child: const Icon(
                          Icons.sports,
                          color: Color(0xFF1A237E),
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Loading Tournament...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: widget.tournamentType == TournamentType.roundRobin
                        ? _buildRoundRobinView()
                        : _buildEliminationBracket(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tournament Bracket',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.tournamentType == TournamentType.roundRobin 
                      ? 'Round Robin Format' 
                      : 'Elimination Format',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEliminationBracket() {
    final rounds = roundMatches.keys.toList()..sort();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rounds.asMap().entries.map((entry) {
            int roundIndex = entry.key;
            int round = entry.value;
            final roundMatchesList = roundMatches[round]!;
            
            return AnimatedBuilder(
              animation: _bracketController,
              builder: (context, child) {
                final animationValue = Curves.easeOutBack.transform(
                  (_bracketController.value - (roundIndex * 0.2)).clamp(0.0, 1.0),
                );
                
                return Transform.translate(
                  offset: Offset(100 * (1 - animationValue), 0),
                  child: Opacity(
                    opacity: animationValue.clamp(0.0, 1.0),
                    child: Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 20),
                      child: Column(
                        children: [
                          _buildRoundHeader(round, rounds.length),
                          const SizedBox(height: 20),
                          ...roundMatchesList.asMap().entries.map((matchEntry) {
                            int matchIndex = matchEntry.key;
                            TournamentMatch match = matchEntry.value;
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 600 + (matchIndex * 200)),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: _buildBracketMatchCard(match, roundIndex),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoundHeader(int round, int totalRounds) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF66BB6A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sports_soccer,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _getRoundName(round, totalRounds),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketMatchCard(TournamentMatch match, int roundIndex) {
    bool isCompleted = match.status == 'Completed';
    bool hasWinner = match.winnerId != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted 
              ? [Colors.white, const Color(0xFFF8F9FA)]
              : [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey.withOpacity(0.3),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted 
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Team 1
          _buildTeamRow(
            teamName: match.team1Name ?? 'TBD',
            score: match.team1Score,
            isWinner: hasWinner && match.winnerId == match.team1Id,
            isCompleted: isCompleted,
            isTop: true,
          ),
          
          // VS Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Team 2
          _buildTeamRow(
            teamName: match.team2Name ?? 'TBD',
            score: match.team2Score,
            isWinner: hasWinner && match.winnerId == match.team2Id,
            isCompleted: isCompleted,
            isTop: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow({
    required String teamName,
    required int score,
    required bool isWinner,
    required bool isCompleted,
    required bool isTop,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isWinner 
            ? LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.1),
                  const Color(0xFF66BB6A).withOpacity(0.05),
                ],
              )
            : null,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTop ? 20 : 0),
          topRight: Radius.circular(isTop ? 20 : 0),
          bottomLeft: Radius.circular(!isTop ? 20 : 0),
          bottomRight: Radius.circular(!isTop ? 20 : 0),
        ),
      ),
      child: Row(
        children: [
          // Team Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isWinner 
                    ? [const Color(0xFFFFD700), const Color(0xFFFFA000)]
                    : [Colors.grey.shade300, Colors.grey.shade400],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWinner ? Icons.emoji_events : Icons.group,
              color: isWinner ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Team Name
          Expanded(
            child: Text(
              teamName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                color: isWinner ? const Color(0xFF1A237E) : Colors.grey.shade800,
              ),
            ),
          ),
          
          // Score
          if (isCompleted) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isWinner 
                      ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                      : [Colors.grey.shade400, Colors.grey.shade500],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                score.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ] else ...[
            Icon(
              Icons.schedule,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoundRobinView() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600 + (index * 100)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: _buildRoundRobinMatchCard(matches[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRoundRobinMatchCard(TournamentMatch match) {
    bool isCompleted = match.status == 'Completed';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey.withOpacity(0.3),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Add match details navigation if needed
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Match Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCompleted 
                          ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                          : [const Color(0xFF2196F3), const Color(0xFF42A5F5)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.schedule,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Match Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${match.team1Name ?? 'TBD'} vs ${match.team2Name ?? 'TBD'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.status,
                        style: TextStyle(
                          color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Score or Status
                if (isCompleted) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${match.team1Score} - ${match.team2Score}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRoundName(int round, int totalRounds) {
    final remainingRounds = totalRounds - round + 1;
    switch (remainingRounds) {
      case 1:
        return 'Final';
      case 2:
        return 'Semi Final';
      case 3:
        return 'Quarter Final';
      case 4:
        return 'Round of 16';
      default:
        return 'Round $round';
    }
  }
}
