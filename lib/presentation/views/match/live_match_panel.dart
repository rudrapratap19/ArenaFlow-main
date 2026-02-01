import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/match/match_model.dart';
import '../../blocs/match/match_bloc.dart';
import '../../blocs/match/match_event.dart';

class LiveMatchPanel extends StatefulWidget {
  final MatchModel match;

  const LiveMatchPanel({super.key, required this.match});

  @override
  State<LiveMatchPanel> createState() => _LiveMatchPanelState();
}

class _LiveMatchPanelState extends State<LiveMatchPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _commentaryController = TextEditingController();
  final _minuteController = TextEditingController();
  final _playerNameController = TextEditingController();
  final _goalsController = TextEditingController();
  final _assistsController = TextEditingController();
  final _yellowCardsController = TextEditingController();
  final _redCardsController = TextEditingController();
  String? _selectedTeam;
  String? _selectedTeamForStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _minuteController.text = '0';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentaryController.dispose();
    _minuteController.dispose();
    _playerNameController.dispose();
    _goalsController.dispose();
    _assistsController.dispose();
    _yellowCardsController.dispose();
    _redCardsController.dispose();
    super.dispose();
  }

  void _addCommentary() {
    if (_commentaryController.text.isEmpty ||
        _selectedTeam == null ||
        _minuteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final commentary = Commentary(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      teamId: _selectedTeam == 'Team 1' ? widget.match.team1Id : widget.match.team2Id,
      teamName: _selectedTeam == 'Team 1' ? widget.match.team1Name : widget.match.team2Name,
      message: _commentaryController.text.trim(),
      minute: int.tryParse(_minuteController.text) ?? 0,
      timestamp: DateTime.now(),
    );

    context.read<MatchBloc>().add(
      CommentaryAddRequested(
        matchId: widget.match.id,
        commentary: commentary,
      ),
    );

    _commentaryController.clear();
    _selectedTeam = null;
    setState(() {}); // Trigger rebuild to reset form

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Commentary added successfully! Updates will appear in real-time.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _updatePlayerStats() {
    if (_playerNameController.text.isEmpty ||
        _selectedTeamForStats == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    final playerStat = PlayerStat(
      playerId: _playerNameController.text.trim(),
      playerName: _playerNameController.text.trim(),
      teamId: _selectedTeamForStats == 'Team 1' ? widget.match.team1Id : widget.match.team2Id,
      teamName:
          _selectedTeamForStats == 'Team 1' ? widget.match.team1Name : widget.match.team2Name,
      goals: int.tryParse(_goalsController.text) ?? 0,
      assists: int.tryParse(_assistsController.text) ?? 0,
      yellowCards: int.tryParse(_yellowCardsController.text) ?? 0,
      redCards: int.tryParse(_redCardsController.text) ?? 0,
      timestamp: DateTime.now(),
    );

    context.read<MatchBloc>().add(
      PlayerStatUpdateRequested(
        matchId: widget.match.id,
        playerStat: playerStat,
      ),
    );

    _playerNameController.clear();
    _goalsController.text = '0';
    _assistsController.text = '0';
    _yellowCardsController.text = '0';
    _redCardsController.text = '0';
    _selectedTeamForStats = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Player stats updated successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
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
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(
                  icon: Icon(Icons.comment_outlined, size: 20),
                  text: 'Commentary',
                ),
                Tab(
                  icon: Icon(Icons.sports_score, size: 20),
                  text: 'Player Stats',
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
                // Commentary Tab
                _buildCommentaryTab(),

                // Player Stats Tab
                _buildPlayerStatsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.edit_note,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Commentary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Record match events in real-time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Team Selection
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Team',
                labelStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.transparent,
                prefixIcon: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.groups, color: AppColors.primary, size: 20),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'Team 1',
                  child: Text(
                    widget.match.team1Name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DropdownMenuItem(
                  value: 'Team 2',
                  child: Text(
                    widget.match.team2Name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedTeam = value);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Minute Input
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _minuteController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Match Minute',
                labelStyle: TextStyle(color: Colors.grey[700]),
                hintText: "e.g., 45",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.timer, color: Colors.orange[700], size: 20),
                ),
                suffixText: "min",
                suffixStyle: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Commentary Input
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _commentaryController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Commentary',
                labelStyle: TextStyle(color: Colors.grey[700]),
                hintText: 'Enter match commentary or important event...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Add Button
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _addCommentary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Commentary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Commentary History
          if (widget.match.commentaries.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Recent Commentaries',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...widget.match.commentaries.reversed.take(5).map((commentary) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.grey[50]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary.withOpacity(0.15),
                                          AppColors.primary.withOpacity(0.08),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      commentary.teamName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.timer, size: 12, color: Colors.orange[700]),
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
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update Player Stats',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Team Selection
          DropdownButtonFormField<String>(
            value: _selectedTeamForStats,
            items: [
              DropdownMenuItem(
                value: 'Team 1',
                child: Text(widget.match.team1Name),
              ),
              DropdownMenuItem(
                value: 'Team 2',
                child: Text(widget.match.team2Name),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedTeamForStats = value);
            },
            decoration: InputDecoration(
              labelText: 'Select Team',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: Icon(Icons.groups, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 12),

          // Player Name Input
          TextFormField(
            controller: _playerNameController,
            decoration: InputDecoration(
              labelText: 'Player Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 12),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildStatInput('Goals', _goalsController, Icons.sports_soccer),
              _buildStatInput('Assists', _assistsController, Icons.psychology),
              _buildStatInput('Yellow Cards', _yellowCardsController, Icons.warning),
              _buildStatInput('Red Cards', _redCardsController, Icons.cancel),
            ],
          ),
          const SizedBox(height: 16),

          // Update Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _updatePlayerStats,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Update Stats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Player Stats Summary
          if (widget.match.playerStats.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Performers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.match.playerStats.take(5).map((stat) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stat.playerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  stat.teamName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                if (stat.goals > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${stat.goals}G',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                if (stat.assists > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${stat.assists}A',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatInput(
      String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 18),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }
}
