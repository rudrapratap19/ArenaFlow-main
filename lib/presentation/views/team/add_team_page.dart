import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/team/team_model.dart';
import '../../blocs/team/team_bloc.dart';

class AddTeamPage extends StatefulWidget {
  final TeamModel? team;

  const AddTeamPage({super.key, this.team});

  @override
  State<AddTeamPage> createState() => _AddTeamPageState();
}

class _AddTeamPageState extends State<AddTeamPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedSport = AppConstants.sportFootball;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.team != null) {
      _nameController.text = widget.team!.name;
      _selectedSport = widget.team!.sport;
    }

    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.defaultAnimationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final team = TeamModel(
        id: widget.team?.id ?? '',
        name: _nameController.text.trim(),
        sport: _selectedSport,
        createdAt: widget.team?.createdAt ?? DateTime.now(),
        playerCount: widget.team?.playerCount ?? 0,
      );

      if (widget.team == null) {
        context.read<TeamBloc>().add(TeamCreateRequested(team: team));
      } else {
        context.read<TeamBloc>().add(TeamUpdateRequested(team: team));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeamBloc, TeamState>(
      listener: (context, state) {
        if (state is TeamOperationSuccess) {
          Helpers.showSnackBar(context, state.message);
          Navigator.pop(context);
        } else if (state is TeamError) {
          Helpers.showSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.team == null ? 'Add Team' : 'Edit Team'),
          backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sport selection
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: Helpers.getSportGradient(_selectedSport),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Helpers.getSportColor(_selectedSport)
                                .withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Helpers.getSportIcon(_selectedSport),
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Select Sport',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
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
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white,
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
                                            ? Helpers.getSportColor(sport)
                                            : Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        sport,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Helpers.getSportColor(sport)
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Team name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Team Name',
                        prefixIcon: const Icon(Icons.groups),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter team name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: BlocBuilder<TeamBloc, TeamState>(
                        builder: (context, state) {
                          final isLoading = state is TeamLoading;
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
                                : Text(
                                    widget.team == null
                                        ? 'Create Team'
                                        : 'Update Team',
                                    style: const TextStyle(
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
      ),
    );
  }
}
