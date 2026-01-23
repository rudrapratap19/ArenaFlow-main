import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/match/match_model.dart';
import '../../../data/models/tournament/tournament_model.dart';
import '../../blocs/match/match_bloc.dart';
import '../../blocs/match/match_event.dart';

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
    );
    context.read<MatchBloc>().add(MatchCreateRequested(match: match));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Match'),
      backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _team1Controller,
                decoration: const InputDecoration(labelText: 'Team 1'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter team 1' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _team2Controller,
                decoration: const InputDecoration(labelText: 'Team 2'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter team 2' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue'),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text('Scheduled: ${_scheduled.toLocal()}'),
                trailing: const Icon(Icons.edit_calendar),
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
                        _scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Create Match'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
