import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/tournament/tournament_model.dart';
import '../../../data/models/match/match_model.dart';
import '../../blocs/tournament/tournament_bloc.dart';

class TournamentDetailsPage extends StatefulWidget {
  final TournamentModel tournament;

  const TournamentDetailsPage({super.key, required this.tournament});

  @override
  State<TournamentDetailsPage> createState() => _TournamentDetailsPageState();
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<TournamentBloc>()
        .add(TournamentLoadRequested(tournamentId: widget.tournament.id));
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.name),
        backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRouter.bracketView,
              arguments: t,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRouter.standings,
              arguments: t,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRouter.matchMaking,
          arguments: t,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Match'),
      ),
      body: BlocBuilder<TournamentBloc, TournamentState>(
        builder: (context, state) {
          if (state is TournamentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TournamentDetailLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.matches.length,
              itemBuilder: (context, index) {
                final m = state.matches[index];
                return _matchCard(m);
              },
            );
          }
          if (state is TournamentError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _matchCard(MatchModel m) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text('${m.team1Name} vs ${m.team2Name}'),
        subtitle: Text(
          '${Helpers.formatDateTime(m.scheduledTime)} · ${m.matchType?.toString().split('.').last ?? 'match'}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(m.status, style: TextStyle(color: Helpers.getStatusColor(m.status))),
            if (m.team1Score != null && m.team2Score != null)
              Text('${m.team1Score} - ${m.team2Score}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.matchDetails,
          arguments: m,
        ),
      ),
    );
  }
}
