import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchDetailsPage extends StatefulWidget {
  final String matchId;

  const MatchDetailsPage({super.key, required this.matchId});

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage>
    with TickerProviderStateMixin {
  final TextEditingController team1ScoreController = TextEditingController();
  final TextEditingController team2ScoreController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController matchTimeController = TextEditingController();

  String? selectedStatus;
  List<Map<String, dynamic>> team1Members = [];
  List<Map<String, dynamic>> team2Members = [];
  Map<String, TextEditingController> performanceControllers = {};
  bool isLoading = true;
  bool isSaving = false;

  // Match data
  String team1Name = '';
  String team2Name = '';
  String? team1Id;
  String? team2Id;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _scoreController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _listenToMatchData();
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
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.bounceOut),
    );

    _scoreAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _scoreController.dispose();
    team1ScoreController.dispose();
    team2ScoreController.dispose();
    venueController.dispose();
    matchTimeController.dispose();
    for (var controller in performanceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _listenToMatchData() {
    FirebaseFirestore.instance
        .collection('matches')
        .doc(widget.matchId)
        .snapshots()
        .listen((matchSnapshot) {
      if (matchSnapshot.exists) {
        final matchData = matchSnapshot.data() as Map<String, dynamic>;
        _updateMatchFields(matchData);
        _loadTeamMembers(matchData['team1Id'], matchData['team2Id']);
      }
    });
  }

  void _updateMatchFields(Map<String, dynamic> matchData) {
    setState(() {
      team1Name = matchData['team1'] ?? '';
      team2Name = matchData['team2'] ?? '';
      team1Id = matchData['team1Id'];
      team2Id = matchData['team2Id'];
      venueController.text = matchData['venue'] ?? '';
      matchTimeController.text = matchData['matchTime'] ?? '';
      team1ScoreController.text = matchData['team1Score']?.toString() ?? '0';
      team2ScoreController.text = matchData['team2Score']?.toString() ?? '0';
      selectedStatus = matchData['status'] ?? matchData['matchStatus'] ?? 'Scheduled';
      isLoading = false;
    });

    // Start animations after data is loaded
    _fadeController.forward();
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  Future<void> _loadTeamMembers(String? team1Id, String? team2Id) async {
    try {
      if (team1Id != null) {
        QuerySnapshot team1Snapshot = await FirebaseFirestore.instance
            .collection('teams')
            .doc(team1Id)
            .collection('members')
            .orderBy('jerseyNumber')
            .get();
        
        team1Members = team1Snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String memberId = doc.id;
          
          if (!performanceControllers.containsKey(memberId)) {
            performanceControllers[memberId] = TextEditingController();
          }
          
          return {'id': memberId, ...data};
        }).toList();
      }

      if (team2Id != null) {
        QuerySnapshot team2Snapshot = await FirebaseFirestore.instance
            .collection('teams')
            .doc(team2Id)
            .collection('members')
            .orderBy('jerseyNumber')
            .get();
        
        team2Members = team2Snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String memberId = doc.id;
          
          if (!performanceControllers.containsKey(memberId)) {
            performanceControllers[memberId] = TextEditingController();
          }
          
          return {'id': memberId, ...data};
        }).toList();
      }

      await _loadExistingPerformanceData();
      setState(() {});
    } catch (e) {
      _showSnackBar('Error loading team members: $e', isError: true);
    }
  }

  Future<void> _loadExistingPerformanceData() async {
    try {
      final performanceSnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.matchId)
          .collection('memberPerformance')
          .get();
      
      for (var doc in performanceSnapshot.docs) {
        final memberId = doc.id;
        final performanceData = doc.data();
        
        if (performanceControllers.containsKey(memberId)) {
          performanceControllers[memberId]!.text = performanceData['performance'] ?? '';
        }
      }
    } catch (e) {
      print("Error loading performance data: $e");
    }
  }

  Future<void> _updateMatchInfo() async {
    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('matches').doc(widget.matchId).update({
        'venue': venueController.text,
        'matchTime': matchTimeController.text,
        'team1Score': int.tryParse(team1ScoreController.text) ?? 0,
        'team2Score': int.tryParse(team2ScoreController.text) ?? 0,
        'status': selectedStatus,
        'matchStatus': selectedStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await _saveMemberPerformance(team1Members);
      await _saveMemberPerformance(team2Members);

      _showSnackBar('Match updated successfully!', isError: false);
    } catch (e) {
      _showSnackBar('Failed to update match: $e', isError: true);
    }

    setState(() => isSaving = false);
  }

  Future<void> _saveMemberPerformance(List<Map<String, dynamic>> teamMembers) async {
    final batch = FirebaseFirestore.instance.batch();
    
    for (var member in teamMembers) {
      String memberId = member['id'];
      String performance = performanceControllers[memberId]?.text ?? '';
      
      String playerName = member['name'] ?? member['memberName'] ?? 'Unknown';
      String playerRole = member['position'] ?? member['role'] ?? 'Player';
      int jerseyNumber = member['jerseyNumber'] ?? 0;
      
      final performanceRef = FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.matchId)
          .collection('memberPerformance')
          .doc(memberId);

      batch.set(performanceRef, {
        'name': playerName,
        'role': playerRole,
        'position': playerRole,
        'jerseyNumber': jerseyNumber,
        'performance': performance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  void _updateScore(bool isTeam1, bool isIncrement) {
    final controller = isTeam1 ? team1ScoreController : team2ScoreController;
    int currentScore = int.tryParse(controller.text) ?? 0;
    
    if (isIncrement) {
      controller.text = (currentScore + 1).toString();
    } else if (currentScore > 0) {
      controller.text = (currentScore - 1).toString();
    }
    
    // Trigger score animation
    _scoreController.forward().then((_) {
      _scoreController.reverse();
    });
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getPlayerName(Map<String, dynamic> member) {
    return member['name'] ?? member['memberName'] ?? 'Unknown Player';
  }

  String _getPlayerRole(Map<String, dynamic> member) {
    return member['position'] ?? member['role'] ?? 'Player';
  }

  @override
  Widget build(BuildContext context) {
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
                child: isLoading ? _buildLoadingView() : _buildMainContent(),
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
                  'Match Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Live Match Management',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isSaving ? null : _updateMatchInfo,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSaving
                    ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
                    : const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
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
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.white70],
                    ),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: Color(0xFF1A237E),
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'Loading Match Details...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMatchHeader(),
                const SizedBox(height: 24),
                _buildMatchInfo(),
                const SizedBox(height: 24),
                _buildScoreSection(),
                const SizedBox(height: 24),
                _buildQuickScoreButtons(),
                const SizedBox(height: 24),
                if (team1Members.isNotEmpty) _buildTeamPerformance(team1Name, team1Members, true),
                if (team2Members.isNotEmpty) _buildTeamPerformance(team2Name, team2Members, false),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$team1Name vs $team2Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ScaleTransition(
            scale: _scoreAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScoreDisplay(team1ScoreController.text, true),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    '-',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildScoreDisplay(team2ScoreController.text, false),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(selectedStatus ?? 'Scheduled').withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(selectedStatus ?? 'Scheduled').withOpacity(0.5),
              ),
            ),
            child: Text(
              selectedStatus ?? 'Scheduled',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(String score, bool isTeam1) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          score,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'in progress':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF2196F3);
    }
  }

  Widget _buildMatchInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Match Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: venueController,
          label: 'Venue',
          icon: Icons.location_on,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: matchTimeController,
          label: 'Match Time',
          icon: Icons.access_time,
        ),
        const SizedBox(height: 16),
        _buildStatusDropdown(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedStatus,
        decoration: InputDecoration(
          labelText: 'Match Status',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(selectedStatus ?? 'Scheduled'),
                  _getStatusColor(selectedStatus ?? 'Scheduled').withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.flag, color: Colors.white, size: 20),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
        ),
        items: ['Scheduled', 'In Progress', 'Completed']
            .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedStatus = value;
          });
        },
      ),
    );
  }

  Widget _buildScoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Scores',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildScoreTextField(
                controller: team1ScoreController,
                label: '$team1Name Score',
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildScoreTextField(
                controller: team2ScoreController,
                label: '$team2Name Score',
                color: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreTextField({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sports, color: Colors.white, size: 20),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: color, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickScoreButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Score Update',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTeamScoreButtons(team1Name, true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTeamScoreButtons(team2Name, false)),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamScoreButtons(String teamName, bool isTeam1) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTeam1 
              ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
              : [const Color(0xFF2196F3), const Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: (isTeam1 ? const Color(0xFF4CAF50) : const Color(0xFF2196F3)).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            teamName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreButton(
                label: '+1',
                color: Colors.white,
                textColor: isTeam1 ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                onPressed: () => _updateScore(isTeam1, true),
              ),
              _buildScoreButton(
                label: '-1',
                color: Colors.red,
                textColor: Colors.white,
                onPressed: () => _updateScore(isTeam1, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamPerformance(String teamName, List<Map<String, dynamic>> members, bool isTeam1) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          '$teamName Players Performance',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 16),
        ...members.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> member = entry.value;
          
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(50 * (1 - value), 0),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: _buildPlayerCard(member, isTeam1),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> member, bool isTeam1) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: (isTeam1 ? const Color(0xFF4CAF50) : const Color(0xFF2196F3)).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isTeam1 
                          ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                          : [const Color(0xFF2196F3), const Color(0xFF42A5F5)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      member['jerseyNumber']?.toString() ?? '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPlayerName(member),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isTeam1 ? const Color(0xFF4CAF50) : const Color(0xFF2196F3)).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getPlayerRole(member),
                          style: TextStyle(
                            color: isTeam1 ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: performanceControllers[member['id']],
                decoration: InputDecoration(
                  labelText: 'Performance Notes',
                  hintText: 'e.g., 2 Goals, 1 Yellow Card, Man of the Match',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isTeam1 ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: isSaving ? null : _updateMatchInfo,
            child: Center(
              child: isSaving
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Saving...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Save All Updates',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
