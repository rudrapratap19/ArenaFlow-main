import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/tournament/tournament_model.dart';
import '../../../data/models/match/match_model.dart';
import '../../blocs/tournament/tournament_bloc.dart';

class BracketViewPage extends StatefulWidget {
  final TournamentModel tournament;

  const BracketViewPage({super.key, required this.tournament});

  @override
  State<BracketViewPage> createState() => _BracketViewPageState();
}

class _BracketViewPageState extends State<BracketViewPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<TournamentBloc>()
        .add(TournamentLoadRequested(tournamentId: widget.tournament.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bracket'),
      backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white,),
      body: BlocBuilder<TournamentBloc, TournamentState>(
        builder: (context, state) {
          if (state is TournamentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TournamentDetailLoaded) {
            return _buildBracket(state.matches);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildBracket(List<MatchModel> matches) {
    final rounds = <int, List<MatchModel>>{};
    for (final m in matches) {
      final r = m.round ?? 1;
      rounds.putIfAbsent(r, () => []).add(m);
    }
    final sortedRounds = rounds.keys.toList()..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in sortedRounds)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Round $r', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final m in rounds[r]!)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12, right: 16),
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.matchType?.toString().split('.').last ?? ''),
                        const SizedBox(height: 6),
                        Text(m.team1Name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(m.team2Name),
                        if (m.team1Score != null && m.team2Score != null) ...[
                          const SizedBox(height: 6),
                          Text('${m.team1Score} - ${m.team2Score}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
