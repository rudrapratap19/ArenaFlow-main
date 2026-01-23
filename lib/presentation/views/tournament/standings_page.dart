import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/tournament/tournament_model.dart';
import '../../blocs/tournament/tournament_bloc.dart';

class StandingsPage extends StatefulWidget {
  final TournamentModel tournament;

  const StandingsPage({super.key, required this.tournament});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TournamentBloc>().add(
          TournamentStandingsLoadRequested(tournamentId: widget.tournament.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Standings'),
      backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white,),
      body: BlocBuilder<TournamentBloc, TournamentState>(
        builder: (context, state) {
          if (state is TournamentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TournamentStandingsLoaded) {
            final standings = state.standings;
            return ListView.builder(
              itemCount: standings.length,
              itemBuilder: (context, index) {
                final row = standings[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(row['teamId'] ?? 'Team'),
                  subtitle: Text('Pts: ${row['points']}  GD: ${row['gd']}'),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
