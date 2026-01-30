import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/match/match_model.dart';
import '../../blocs/match/match_bloc.dart';
import '../../blocs/match/match_event.dart';
import '../../blocs/match/match_state.dart';

class MatchDetailsPage extends StatefulWidget {
  final MatchModel match;

  const MatchDetailsPage({super.key, required this.match});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _score1Controller = TextEditingController();
  final _score2Controller = TextEditingController();
  final _venueController = TextEditingController();
  
  late DateTime _scheduledTime;
  late String _selectedStatus;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    context
        .read<MatchBloc>()
        .add(MatchLoadByIdRequested(matchId: widget.match.id));
  }

  void _initializeFields() {
    _score1Controller.text = widget.match.team1Score.toString();
    _score2Controller.text = widget.match.team2Score.toString();
    _venueController.text = widget.match.venue;
    _scheduledTime = widget.match.scheduledTime;
    _selectedStatus = widget.match.status;
  }

  @override
  void dispose() {
    _score1Controller.dispose();
    _score2Controller.dispose();
    _venueController.dispose();
    super.dispose();
  }

  void _updateMatch(MatchModel currentMatch) {
    if (!_formKey.currentState!.validate()) return;

    final updatedMatch = MatchModel(
      id: currentMatch.id,
      tournamentId: currentMatch.tournamentId,
      team1Id: currentMatch.team1Id,
      team2Id: currentMatch.team2Id,
      team1Name: currentMatch.team1Name,
      team2Name: currentMatch.team2Name,
      team1Score: int.tryParse(_score1Controller.text.trim()) ?? currentMatch.team1Score,
      team2Score: int.tryParse(_score2Controller.text.trim()) ?? currentMatch.team2Score,
      winnerId: currentMatch.winnerId,
      loserId: currentMatch.loserId,
      sport: currentMatch.sport,
      venue: _venueController.text.trim(),
      scheduledTime: _scheduledTime,
      status: _selectedStatus,
      matchType: currentMatch.matchType,
      round: currentMatch.round,
      position: currentMatch.position,
      createdAt: currentMatch.createdAt,
    );

    context.read<MatchBloc>().add(MatchUpdateRequested(match: updatedMatch));
    setState(() => _isEditing = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Match updated successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledTime),
      );
      if (time != null) {
        setState(() {
          _scheduledTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
            tooltip: _isEditing ? 'Cancel' : 'Edit',
          ),
        ],
      ),
      body: BlocConsumer<MatchBloc, MatchState>(
        listener: (context, state) {
          if (state is MatchDetailLoaded) {
            // Update fields when match is reloaded
            _score1Controller.text = state.match.team1Score.toString();
            _score2Controller.text = state.match.team2Score.toString();
            _venueController.text = state.match.venue;
            _scheduledTime = state.match.scheduledTime;
            _selectedStatus = state.match.status;
          }
        },
        builder: (context, state) {
          MatchModel match = widget.match;
          if (state is MatchDetailLoaded) {
            match = state.match;
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section with Gradient
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: Helpers.getSportGradient(match.sport),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Sport Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Helpers.getSportIcon(match.sport),
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Match Title
                        Text(
                          match.sport.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Helpers.getStatusColor(_selectedStatus).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _selectedStatus == 'Live' ? Colors.white : Colors.white70,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedStatus.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Teams and Scores Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Team 1
                        _buildTeamCard(
                          match.team1Name,
                          _score1Controller,
                          match.team1Score,
                          true,
                        ),
                        
                        // VS Divider
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'VS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                            ],
                          ),
                        ),
                        
                        // Team 2
                        _buildTeamCard(
                          match.team2Name,
                          _score2Controller,
                          match.team2Score,
                          false,
                        ),
                      ],
                    ),
                  ),

                  // Match Details Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Match Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        
                        // Status Selector
                        _buildInfoTile(
                          icon: Icons.radio_button_checked,
                          title: 'Status',
                          child: _isEditing
                              ? Wrap(
                                  spacing: 8,
                                  children: ['Scheduled', 'Live', 'Completed'].map((status) {
                                    final isSelected = status == _selectedStatus;
                                    return FilterChip(
                                      label: Text(status),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _selectedStatus = status);
                                        }
                                      },
                                      selectedColor: Helpers.getStatusColor(status).withOpacity(0.3),
                                      checkmarkColor: Helpers.getStatusColor(status),
                                      labelStyle: TextStyle(
                                        color: isSelected ? Helpers.getStatusColor(status) : Colors.grey[700],
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Helpers.getStatusColor(_selectedStatus).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _selectedStatus,
                                    style: TextStyle(
                                      color: Helpers.getStatusColor(_selectedStatus),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),
                        
                        // Venue
                        _buildInfoTile(
                          icon: Icons.location_on,
                          title: 'Venue',
                          child: _isEditing
                              ? TextFormField(
                                  controller: _venueController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter venue',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Venue is required';
                                    }
                                    return null;
                                  },
                                )
                              : Text(
                                  match.venue.isEmpty ? 'TBD' : match.venue,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[800],
                                  ),
                                ),
                        ),
                        
                        // Scheduled Time
                        _buildInfoTile(
                          icon: Icons.access_time,
                          title: 'Scheduled Time',
                          child: _isEditing
                              ? InkWell(
                                  onTap: _selectDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[400]!),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          Helpers.formatDateTime(_scheduledTime),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                                      ],
                                    ),
                                  ),
                                )
                              : Text(
                                  Helpers.formatDateTime(match.scheduledTime),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[800],
                                  ),
                                ),
                        ),

                        // Match Type
                        if (match.matchType != null)
                          _buildInfoTile(
                            icon: Icons.category,
                            title: 'Match Type',
                            child: Text(
                              match.matchType.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        // Round
                        if (match.round != null)
                          _buildInfoTile(
                            icon: Icons.numbers,
                            title: 'Round',
                            child: Text(
                              'Round ${match.round}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Save Button
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _updateMatch(match),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamCard(String teamName, TextEditingController controller, int currentScore, bool isTeam1) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Team Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shield,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          
          // Team Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTeam1 ? 'Team 1' : 'Team 2',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Score
          Container(
            width: _isEditing ? 80 : 60,
            child: _isEditing
                ? TextFormField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '';
                      }
                      if (int.tryParse(value) == null) {
                        return '';
                      }
                      return null;
                    },
                  )
                : Text(
                    currentScore.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
