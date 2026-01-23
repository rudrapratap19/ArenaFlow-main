import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/tournament/tournament_model.dart';
import '../../../data/models/team/team_model.dart';
import '../../blocs/tournament/tournament_bloc.dart';
import '../../blocs/team/team_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';

class CreateTournamentPage extends StatefulWidget {
  const CreateTournamentPage({super.key});

  @override
  State<CreateTournamentPage> createState() => _CreateTournamentPageState();
}

class _CreateTournamentPageState extends State<CreateTournamentPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedSport = AppConstants.sportFootball;
  TournamentType _selectedType = TournamentType.singleElimination;
  DateTime _startDate = DateTime.now();
  List<String> _selectedTeamIds = [];
  List<TeamModel> _availableTeams = [];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadTeams();

    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.defaultAnimationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  void _loadTeams() {
    context.read<TeamBloc>().add(TeamLoadRequested(sport: _selectedSport));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTeamIds.length < 2) {
        Helpers.showSnackBar(context, 'Please select at least 2 teams');
        return;
      }

      final authState = context.read<AuthBloc>().state;
      String createdBy = '';
      if (authState is AuthAuthenticated) {
        createdBy = authState.user.uid;
      }

      final tournament = TournamentModel(
        id: '',
        name: _nameController.text.trim(),
        sport: _selectedSport,
        type: _selectedType,
        status: TournamentStatus.registration,
        startDate: _startDate,
        teamIds: _selectedTeamIds,
        settings: {},
        createdAt: DateTime.now(),
        createdBy: createdBy,
      );

      context.read<TournamentBloc>().add(
            TournamentCreateRequested(
              tournament: tournament,
              generateBracket: true,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TournamentBloc, TournamentState>(
      listener: (context, state) {
        if (state is TournamentOperationSuccess) {
          Helpers.showSnackBar(context, state.message);
          Navigator.pop(context);
        } else if (state is TournamentError) {
          Helpers.showSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Tournament'),
          backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tournament name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Tournament Name',
                      prefixIcon: const Icon(Icons.emoji_events),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter tournament name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Sport selection
                  const Text(
                    'Select Sport',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      AppConstants.sportFootball,
                      AppConstants.sportCricket,
                      AppConstants.sportBasketball,
                      AppConstants.sportVolleyball,
                    ].map((sport) {
                      final isSelected = sport == _selectedSport;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSport = sport;
                            _selectedTeamIds.clear();
                          });
                          _loadTeams();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? (Helpers.getSportGradient(sport) != null
                                    ? LinearGradient(
                                        colors: Helpers.getSportGradient(sport)!,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null)
                                : null,
                            color: isSelected ? null : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Helpers.getSportColor(sport)
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Helpers.getSportIcon(sport),
                                size: 20,
                                color: isSelected
                                    ? Colors.white
                                    : Helpers.getSportColor(sport),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                sport,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Tournament type
                  const Text(
                    'Tournament Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<TournamentType>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.format_list_bulleted),
                    ),
                    items: TournamentType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type.toString().split('.').last.replaceAllMapped(
                                      RegExp(r'([A-Z])'),
                                      (match) => ' ${match.group(0)}',
                                    ).trim(),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Start date
                  const Text(
                    'Start Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    leading: const Icon(Icons.calendar_today),
                    title: Text(Helpers.formatDate(_startDate)),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Team selection
                  const Text(
                    'Select Teams',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<TeamBloc, TeamState>(
                    builder: (context, state) {
                      if (state is TeamLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is TeamLoaded) {
                        _availableTeams = state.teams;

                        if (_availableTeams.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'No teams available for this sport.\nPlease create teams first.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _availableTeams.length,
                            itemBuilder: (context, index) {
                              final team = _availableTeams[index];
                              final isSelected =
                                  _selectedTeamIds.contains(team.id);
                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedTeamIds.add(team.id);
                                    } else {
                                      _selectedTeamIds.remove(team.id);
                                    }
                                  });
                                },
                                title: Text(team.name),
                                subtitle: Text('${team.playerCount} players'),
                                secondary: Icon(
                                  Helpers.getSportIcon(team.sport),
                                  color: Helpers.getSportColor(team.sport),
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_selectedTeamIds.length} teams selected',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: BlocBuilder<TournamentBloc, TournamentState>(
                      builder: (context, state) {
                        final isLoading = state is TournamentLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Helpers.getSportColor(_selectedSport),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Create Tournament',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
