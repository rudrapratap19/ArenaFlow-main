class AppConstants {
  // App Info
  static const String appName = 'ArenaFlow';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String teamsCollection = 'teams';
  static const String playersCollection = 'players';
  static const String matchesCollection = 'matches';
  static const String tournamentsCollection = 'tournaments';
  static const String tournamentMatchesCollection = 'tournamentMatches';
  static const String performancesCollection = 'performances';

  // User Roles
  static const String roleAdmin = 'Admin';
  static const String roleUser = 'User';

  // Sports
  static const String sportFootball = 'football';
  static const String sportCricket = 'cricket';
  static const String sportBasketball = 'basketball';
  static const String sportVolleyball = 'volleyball';

  // Match Status
  static const String statusScheduled = 'Scheduled';
  static const String statusLive = 'Live';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';

  // Tournament Types
  static const String tournamentSingleElimination = 'TournamentType.singleElimination';
  static const String tournamentDoubleElimination = 'TournamentType.doubleElimination';
  static const String tournamentRoundRobin = 'TournamentType.roundRobin';

  // Tournament Status
  static const String tournamentRegistration = 'TournamentStatus.registration';
  static const String tournamentInProgress = 'TournamentStatus.inProgress';
  static const String tournamentCompleted = 'TournamentStatus.completed';

  // Shared Preferences Keys
  static const String keyRememberMe = 'remember_me';
  static const String keyUserEmail = 'user_email';
  static const String keyUserPassword = 'user_password';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 800);
  static const Duration shortAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 1200);

  // Delays
  static const Duration splashDelay = Duration(seconds: 2);
  static const Duration snackBarDuration = Duration(seconds: 3);
}
