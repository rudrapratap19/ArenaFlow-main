import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/team/player_model.dart';
import '../../blocs/team/team_bloc.dart';

class AddPlayerPage extends StatefulWidget {
  final String teamId;
  final PlayerModel? player;

  const AddPlayerPage({super.key, required this.teamId, this.player});

  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _jerseyController = TextEditingController();
  final _positionController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _experienceController = TextEditingController();
  final _statsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = widget.player;
    if (p != null) {
      _nameController.text = p.name;
      _jerseyController.text = p.jerseyNumber ?? '';
      _positionController.text = p.position ?? '';
      _ageController.text = p.age?.toString() ?? '';
      _phoneController.text = p.phone ?? '';
      _emailController.text = p.email ?? '';
      _heightController.text = p.height ?? '';
      _weightController.text = p.weight ?? '';
      _experienceController.text = p.experience ?? '';
      _statsController.text = p.statistics ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jerseyController.dispose();
    _positionController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _experienceController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final player = PlayerModel(
      id: widget.player?.id ?? '',
      teamId: widget.teamId,
      name: _nameController.text.trim(),
      jerseyNumber: _jerseyController.text.trim().isEmpty
          ? null
          : _jerseyController.text.trim(),
      position: _positionController.text.trim().isEmpty
          ? null
          : _positionController.text.trim(),
      age: _ageController.text.trim().isEmpty
          ? null
          : int.tryParse(_ageController.text.trim()),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      height: _heightController.text.trim().isEmpty
          ? null
          : _heightController.text.trim(),
      weight: _weightController.text.trim().isEmpty
          ? null
          : _weightController.text.trim(),
      experience: _experienceController.text.trim().isEmpty
          ? null
          : _experienceController.text.trim(),
      statistics: _statsController.text.trim().isEmpty
          ? null
          : _statsController.text.trim(),
      createdAt: widget.player?.createdAt ?? DateTime.now(),
    );

    if (widget.player == null) {
      context.read<TeamBloc>().add(PlayerAddRequested(player: player));
    } else {
      context.read<TeamBloc>().add(PlayerUpdateRequested(player: player));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeamBloc, TeamState>(
      listener: (context, state) {
        if (state is TeamOperationSuccess) {
          Helpers.showSnackBar(context, state.message);
          Navigator.pop(context, true);
        }
        if (state is TeamError) {
          Helpers.showSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.player == null ? 'Add Player' : 'Edit Player'),
          backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submit,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter player name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _jerseyController,
                  decoration: const InputDecoration(
                    labelText: 'Jersey Number',
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position / Role',
                    prefixIcon: Icon(Icons.sports),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v != null && v.isNotEmpty && !v.contains('@')
                          ? 'Enter valid email'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    prefixIcon: Icon(Icons.height),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _experienceController,
                  decoration: const InputDecoration(
                    labelText: 'Experience',
                    prefixIcon: Icon(Icons.timelapse),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _statsController,
                  decoration: const InputDecoration(
                    labelText: 'Statistics',
                    prefixIcon: Icon(Icons.bar_chart),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.player == null ? 'Add Player' : 'Update Player'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
