import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/match/match_model.dart';
import '../../blocs/match/match_bloc.dart';
import '../../blocs/match/match_event.dart'; // Ensure the event file is imported
import '../../blocs/match/match_state.dart'; // Import the MatchState file

class MatchDetailsPage extends StatefulWidget {
  final MatchModel match;

  const MatchDetailsPage({super.key, required this.match});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  final _score1Controller = TextEditingController();
  final _score2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _score1Controller.text = widget.match.team1Score?.toString() ?? '';
    _score2Controller.text = widget.match.team2Score?.toString() ?? '';
    context
        .read<MatchBloc>()
        .add(MatchLoadByIdRequested(matchId: widget.match.id));
  }

  @override
  void dispose() {
    _score1Controller.dispose();
    _score2Controller.dispose();
    super.dispose();
  }

  void _updateScore() {
    final s1 = int.tryParse(_score1Controller.text.trim()) ?? 0;
    final s2 = int.tryParse(_score2Controller.text.trim()) ?? 0;
    context.read<MatchBloc>().add(
          MatchScoreUpdateRequested(
            matchId: widget.match.id,
            team1Score: s1,
            team2Score: s2,
          ),
        );
  }

  void _updateStatus(String status) {
    context.read<MatchBloc>().add(
          MatchStatusUpdateRequested(matchId: widget.match.id, status: status),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Details'),
        backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          MatchModel match = widget.match;
          if (state is MatchDetailLoaded) {
            match = state.match;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('${match.team1Name} vs ${match.team2Name}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Status: ${match.status}',
                  style: TextStyle(color: Helpers.getStatusColor(match.status))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _score1Controller,
                      decoration: InputDecoration(labelText: match.team1Name),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _score2Controller,
                      decoration: InputDecoration(labelText: match.team2Name),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _updateScore,
                child: const Text('Update Score'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final status in ['Scheduled', 'Live', 'Completed'])
                    OutlinedButton(
                      onPressed: () => _updateStatus(status),
                      child: Text(status),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Venue'),
                subtitle: Text(match.venue.isEmpty ? 'TBD' : match.venue),
              ),
              ListTile(
                title: const Text('Scheduled Time'),
                subtitle: Text(Helpers.formatDateTime(match.scheduledTime)),
              ),
            ],
          );
        },
      ),
    );
  }
}
