import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class MatchMakingPage extends StatefulWidget {
  final List<String> teams;
  final String sport;

  const MatchMakingPage({super.key, required this.teams, required this.sport});

  @override
  _MatchMakingPageState createState() => _MatchMakingPageState();
}

class _MatchMakingPageState extends State<MatchMakingPage>
    with TickerProviderStateMixin {
  final List<TextEditingController> _venueControllers = [];
  final List<TextEditingController> _timeControllers = [];
  final Map<int, String> matchIds = {};
  List<Map<String, dynamic>> teamData = [];
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadTeamData();
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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    for (var controller in _venueControllers) {
      controller.dispose();
    }
    for (var controller in _timeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTeamData() async {
    setState(() => _isLoading = true);
    
    for (String teamName in widget.teams) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('teamName', isEqualTo: teamName)
          .where('sport', isEqualTo: widget.sport)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        teamData.add({
          'id': doc.id,
          'name': doc['teamName'],
          'sport': doc['sport'],
        });
      }
    }
    
    _initializeControllers();
    setState(() => _isLoading = false);
    
    // Start animations after loading
    _fadeController.forward();
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  void _initializeControllers() {
    _venueControllers.clear();
    _timeControllers.clear();
    int matchCount = (teamData.length / 2).ceil();
    for (int i = 0; i < matchCount; i++) {
      _venueControllers.add(TextEditingController());
      _timeControllers.add(TextEditingController());
    }
  }

  Future<void> _clearPreviousMatches() async {
    final matchCollection = FirebaseFirestore.instance.collection('matches');
    final snapshot = await matchCollection
        .where('sport', isEqualTo: widget.sport)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _saveMatchesToFirebase(List<List<Map<String, dynamic>>> pairs) async {
    final matchCollection = FirebaseFirestore.instance.collection('matches');
    for (var i = 0; i < pairs.length; i++) {
      var pair = pairs[i];
      if (pair.length == 2 && pair[1]['name'] != "Bye") {
        DocumentReference matchDocRef = await matchCollection.add({
          'team1': pair[0]['name'],
          'team2': pair[1]['name'],
          'team1Id': pair[0]['id'],
          'team2Id': pair[1]['id'],
          'sport': widget.sport,
          'status': 'Scheduled',
          'matchStatus': 'Scheduled',
          'venue': _venueControllers[i].text.isEmpty ? 'TBD' : _venueControllers[i].text,
          'matchTime': _timeControllers[i].text.isEmpty ? 'TBD' : _timeControllers[i].text,
          'scheduledTime': _timeControllers[i].text.isEmpty 
              ? FieldValue.serverTimestamp() 
              : DateTime.tryParse(_timeControllers[i].text) ?? DateTime.now(),
          'team1Score': 0,
          'team2Score': 0,
          'timestamp': FieldValue.serverTimestamp(),
        });
        matchIds[i] = matchDocRef.id;
      }
    }
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
                child: _isLoading ? _buildLoadingView() : _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isLoading ? null : _buildFloatingActionButton(),
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
                  'Match Making',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.sport.toUpperCase()} Tournament',
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
              Icons.sports,
              color: Colors.white,
              size: 24,
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
            'Loading Teams...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Preparing match fixtures',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (widget.teams.isEmpty || teamData.isEmpty) {
      return _buildEmptyState();
    }

    // Shuffle teams and pair them
    List<Map<String, dynamic>> shuffledTeams = List.from(teamData)..shuffle(Random());
    List<List<Map<String, dynamic>>> pairs = [];
    for (int i = 0; i < shuffledTeams.length - 1; i += 2) {
      pairs.add([shuffledTeams[i], shuffledTeams[i + 1]]);
    }

    if (shuffledTeams.length % 2 != 0) {
      pairs.add([shuffledTeams.last, {'name': 'Bye', 'id': 'bye'}]);
    }

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
      child: Column(
        children: [
          _buildMatchCounter(pairs.length),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: pairs.length,
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 600 + (index * 150)),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(100 * (1 - value), 0),
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: _buildMatchCard(pairs[index], index),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No Teams Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add teams for ${widget.sport} to start matchmaking',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCounter(int matchCount) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
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
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            '$matchCount Matches Generated',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(List<Map<String, dynamic>> pair, int index) {
    bool isByeMatch = pair[1]['name'] == 'Bye';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isByeMatch 
              ? [Colors.grey.shade100, Colors.grey.shade200]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isByeMatch ? Colors.grey.shade300 : const Color(0xFF1A237E).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isByeMatch 
                          ? [Colors.grey.shade400, Colors.grey.shade500]
                          : [const Color(0xFF1A237E), const Color(0xFF3949AB)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'M${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${pair[0]['name']} vs ${pair[1]['name']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isByeMatch ? Colors.grey.shade600 : const Color(0xFF1A237E),
                    ),
                  ),
                ),
                if (!isByeMatch)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                    ),
                    child: const Text(
                      'SCHEDULED',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),

            if (!isByeMatch) ...[
              const SizedBox(height: 20),
              
              // Venue Input
              _buildInputField(
                controller: index < _venueControllers.length
                    ? _venueControllers[index]
                    : TextEditingController(),
                label: 'Venue',
                icon: Icons.location_on,
                hint: 'Enter match venue',
              ),
              
              const SizedBox(height: 16),
              
              // Time Input
              _buildInputField(
                controller: index < _timeControllers.length
                    ? _timeControllers[index]
                    : TextEditingController(),
                label: 'Match Time',
                icon: Icons.access_time,
                hint: '2024-12-25 15:30',
                keyboardType: TextInputType.datetime,
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${pair[0]['name']} gets a bye (advances automatically)',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
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
          labelStyle: const TextStyle(color: Color(0xFF1A237E)),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 140,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          ),
          borderRadius: BorderRadius.circular(28),
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
            borderRadius: BorderRadius.circular(28),
            onTap: _isSaving ? null : _saveMatches,
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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

  Future<void> _saveMatches() async {
    setState(() => _isSaving = true);

    try {
      // Prepare pairs again for saving
      List<Map<String, dynamic>> shuffledTeams = List.from(teamData)..shuffle(Random());
      List<List<Map<String, dynamic>>> pairs = [];
      for (int i = 0; i < shuffledTeams.length - 1; i += 2) {
        pairs.add([shuffledTeams[i], shuffledTeams[i + 1]]);
      }

      if (shuffledTeams.length % 2 != 0) {
        pairs.add([shuffledTeams.last, {'name': 'Bye', 'id': 'bye'}]);
      }

      await _clearPreviousMatches();
      await _saveMatchesToFirebase(pairs);
      
      _showSnackBar("Matches have been scheduled successfully!", isError: false);
      
      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      _showSnackBar("Error saving matches: $e", isError: true);
    }

    setState(() => _isSaving = false);
  }
}
