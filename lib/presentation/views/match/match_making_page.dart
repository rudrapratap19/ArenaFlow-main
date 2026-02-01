import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/match/match_model.dart';
import '../../../data/models/tournament/tournament_model.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/match/match_bloc.dart';
import '../../blocs/match/match_event.dart';
import '../../blocs/match/match_state.dart';

class MatchMakingPage extends StatefulWidget {
  final TournamentModel? tournament;

  const MatchMakingPage({super.key, this.tournament});

  @override
  State<MatchMakingPage> createState() => _MatchMakingPageState();
}

class _MatchMakingPageState extends State<MatchMakingPage> {
  final _formKey = GlobalKey<FormState>();
  final _team1Controller = TextEditingController();
  final _team2Controller = TextEditingController();
  final _venueController = TextEditingController();
  DateTime _scheduled = DateTime.now().add(const Duration(hours: 2));

  @override
  void dispose() {
    _team1Controller.dispose();
    _team2Controller.dispose();
    _venueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    final authState = context.read<AuthBloc>().state;
    String currentUserId = '';
    if (authState is AuthAuthenticated) {
      currentUserId = authState.user.uid;
    }

    final match = MatchModel(
      id: '',
      tournamentId: widget.tournament?.id,
      team1Id: _team1Controller.text.trim(),
      team2Id: _team2Controller.text.trim(),
      team1Name: _team1Controller.text.trim(),
      team2Name: _team2Controller.text.trim(),
      sport: widget.tournament?.sport ?? 'football',
      venue: _venueController.text.trim(),
      scheduledTime: _scheduled,
      status: 'Scheduled',
      createdAt: DateTime.now(),
      createdBy: currentUserId,
    );
    context.read<MatchBloc>().add(MatchCreateRequested(match: match));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Match'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<MatchBloc, MatchState>(
        listener: (context, state) {
          if (state is MatchOperationSuccess) {
            Navigator.pop(context, true);
          } else if (state is MatchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Match Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFormSection(
                    title: 'Teams',
                    children: [
                      TextFormField(
                        controller: _team1Controller,
                        decoration: InputDecoration(
                          labelText: 'Team 1',
                          prefixIcon: Icon(Icons.groups, color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter team 1 name' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _team2Controller,
                        decoration: InputDecoration(
                          labelText: 'Team 2',
                          prefixIcon: Icon(Icons.groups, color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter team 2 name' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildFormSection(
                    title: 'Location & Time',
                    children: [
                      TextFormField(
                        controller: _venueController,
                        decoration: InputDecoration(
                          labelText: 'Venue',
                          hintText: 'e.g., Main Stadium',
                          prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildDateTimePicker(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[50],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: Icon(Icons.event_outlined, color: Colors.grey[600]),
        title: const Text(
          'Date & Time',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _scheduled.toLocal().toString().split('.')[0],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(Icons.edit, color: Colors.grey[600], size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _scheduled,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(_scheduled),
            );
            if (time != null) {
              setState(() {
                _scheduled = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
              });
            }
          }
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          final isLoading = state is MatchLoading;
          return ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Schedule Match',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
