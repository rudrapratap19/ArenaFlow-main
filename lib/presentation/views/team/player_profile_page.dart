import 'package:flutter/material.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/team/player_model.dart';

class PlayerProfilePage extends StatelessWidget {
  final PlayerModel player;

  const PlayerProfilePage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(player.name),
        backgroundColor: Colors.blue, // Changed from transparent
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    Helpers.getInitials(player.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (player.position != null)
                      Text(
                        player.position!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _infoTile('Jersey', player.jerseyNumber ?? '-'),
            _infoTile('Age', player.age?.toString() ?? '-'),
            _infoTile('Phone', player.phone ?? '-'),
            _infoTile('Email', player.email ?? '-'),
            _infoTile('Height', player.height ?? '-'),
            _infoTile('Weight', player.weight ?? '-'),
            _infoTile('Experience', player.experience ?? '-'),
            _infoTile('Statistics', player.statistics ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(value),
    );
  }
}
