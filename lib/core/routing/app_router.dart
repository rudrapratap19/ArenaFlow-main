import 'package:flutter/material.dart';
import '../../presentation/views/auth/login_page.dart';
import '../../presentation/views/auth/sign_up_page.dart';
import '../../presentation/views/dashboard/admin_panel.dart';
import '../../presentation/views/dashboard/user_panel.dart';
import '../../presentation/views/team/add_team_page.dart';
import '../../presentation/views/team/teams_list_page.dart';
import '../../presentation/views/team/team_roster_page.dart';
import '../../presentation/views/team/add_player_page.dart';
import '../../presentation/views/team/player_profile_page.dart';
import '../../presentation/views/tournament/tournaments_list_page.dart';
import '../../presentation/views/tournament/create_tournament_page.dart';
import '../../presentation/views/tournament/tournament_details_page.dart';
import '../../presentation/views/tournament/bracket_view_page.dart';
import '../../presentation/views/tournament/standings_page.dart';
import '../../presentation/views/match/scheduled_matches_page.dart';
import '../../presentation/views/match/match_making_page.dart';
import '../../presentation/views/match/match_details_page.dart';
import '../../data/models/team/team_model.dart';
import '../../data/models/team/player_model.dart';
import '../../data/models/tournament/tournament_model.dart';
import '../../data/models/match/match_model.dart';

class AppRouter {
  static const String login = '/';
  static const String signUp = '/signup';
  static const String adminPanel = '/admin';
  static const String userPanel = '/user';

  static const String teamsList = '/teams-list';
  static const String addTeam = '/add-team';
  static const String teamRoster = '/team-roster';
  static const String addPlayer = '/add-player';
  static const String playerProfile = '/player-profile';

  static const String createTournament = '/create-tournament';
  static const String tournamentsList = '/tournaments-list';
  static const String tournamentDetails = '/tournament-details';
  static const String bracketView = '/bracket-view';
  static const String standings = '/standings';

  static const String matchMaking = '/match-making';
  static const String scheduledMatches = '/scheduled-matches';
  static const String matchDetails = '/match-details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      
      case adminPanel:
        return _createRoute(const AdminPanel());
      
      case userPanel:
        return _createRoute(const UserPanel());

      case teamsList:
        final sport = settings.arguments as String?;
        return _buildRoute(TeamsListPage(initialSport: sport));
      case addTeam:
        final team = settings.arguments as TeamModel?;
        return _buildRoute(AddTeamPage(team: team));
      case teamRoster:
        final team = settings.arguments as TeamModel;
        return _buildRoute(TeamRosterPage(team: team));
      case addPlayer:
        if (settings.arguments is Map) {
          final args = settings.arguments as Map;
          final player = args['player'] as PlayerModel?;
          final teamId = args['teamId'] as String;
          return _buildRoute(AddPlayerPage(teamId: teamId, player: player));
        }
        final teamId = settings.arguments as String;
        return _buildRoute(AddPlayerPage(teamId: teamId));
      case playerProfile:
        final player = settings.arguments as PlayerModel;
        return _buildRoute(PlayerProfilePage(player: player));

      case createTournament:
        return _buildRoute(const CreateTournamentPage());
      case tournamentsList:
        return _buildRoute(const TournamentsListPage());
      case tournamentDetails:
        final tournament = settings.arguments as TournamentModel;
        return _buildRoute(TournamentDetailsPage(tournament: tournament));
      case bracketView:
        final tournament = settings.arguments as TournamentModel;
        return _buildRoute(BracketViewPage(tournament: tournament));
      case standings:
        final tournament = settings.arguments as TournamentModel;
        return _buildRoute(StandingsPage(tournament: tournament));

      case matchMaking:
        final tournament = settings.arguments as TournamentModel?;
        return _buildRoute(MatchMakingPage(tournament: tournament));
      case scheduledMatches:
        return _buildRoute(const ScheduledMatchesPage());
      case matchDetails:
        final match = settings.arguments as MatchModel;
        return _buildRoute(MatchDetailsPage(match: match));
      
      // Add more routes as we implement pages
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Route<dynamic> _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }

  static Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
