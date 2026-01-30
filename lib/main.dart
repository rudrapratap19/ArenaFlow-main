import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'data/services/firebase/local_storage_service.dart';
import 'data/services/firebase/firebase_service.dart';
import 'data/repositories/auth/auth_repository.dart';
import 'data/repositories/team/team_repository.dart';
import 'data/repositories/tournament/tournament_repository.dart';
import 'data/repositories/match/match_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/team/team_bloc.dart';
import 'presentation/blocs/tournament/tournament_bloc.dart';
import 'presentation/blocs/match/match_bloc.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'firebase_options.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, 
    );
    
    
    await LocalStorageService().init();
    
    runApp(const ArenaFlowApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize: $e'),
        ),
      ),
    ));
  }
}

class ArenaFlowApp extends StatelessWidget {
  const ArenaFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final localStorageService = LocalStorageService();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            firebaseService: firebaseService,
            localStorageService: localStorageService,
          ),
        ),
        RepositoryProvider<TeamRepository>(
          create: (context) => TeamRepository(firebaseService: firebaseService),
        ),
        RepositoryProvider<TournamentRepository>(
          create: (context) => TournamentRepository(firebaseService: firebaseService),
        ),
        RepositoryProvider<MatchRepository>(
          create: (context) => MatchRepository(firebaseService: firebaseService),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider<TeamBloc>(
            create: (context) => TeamBloc(
              teamRepository: context.read<TeamRepository>(),
            ),
          ),
          BlocProvider<TournamentBloc>(
            create: (context) => TournamentBloc(
              tournamentRepository: context.read<TournamentRepository>(),
            ),
          ),
          BlocProvider<MatchBloc>(
            create: (context) => MatchBloc(
              matchRepository: context.read<MatchRepository>(),
            ),
          ),
          BlocProvider<ThemeCubit>(
            create: (_) => ThemeCubit(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: AppRouter.login,
            );
          },
        ),
      ),
    );
  }
}
