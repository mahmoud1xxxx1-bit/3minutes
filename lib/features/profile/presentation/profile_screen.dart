import 'package:flutter/material.dart';

import '../data/profile_repository.dart';
import '../domain/player_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.profileRepository,
  });

  final PlayerProfile profile;
  final ProfileRepository profileRepository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late String _avatarId;
  bool _saving = false;
  String? _error;

  static const _avatars = <String>[
    'default_01',
    'default_02',
    'default_03',
    'default_04',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.gameName);
    _avatarId = widget.profile.avatarId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.profileRepository.updatePublicProfile(
        uid: widget.profile.uid,
        gameName: _nameController.text,
        avatarId: _avatarId,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } on ArgumentError catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message?.toString());
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not save your profile. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(child: _Stat(label: 'Level', value: '${widget.profile.level}')),
                const SizedBox(width: 10),
                Expanded(child: _Stat(label: 'RP', value: '${widget.profile.rankPoints}')),
                const SizedBox(width: 10),
                Expanded(child: _Stat(label: 'Stars', value: '${widget.profile.stars}')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _Stat(label: 'Wins', value: '${widget.profile.wins}')),
                const SizedBox(width: 10),
                Expanded(child: _Stat(label: 'Losses', value: '${widget.profile.losses}')),
                const SizedBox(width: 10),
                Expanded(
                  child: _Stat(
                    label: 'Played',
                    value: '${widget.profile.gamesPlayed}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _nameController,
              maxLength: 20,
              decoration: const InputDecoration(
                labelText: 'Player name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Avatar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _avatars.map((avatarId) {
                final selected = avatarId == _avatarId;
                final number = _avatars.indexOf(avatarId) + 1;

                return InkWell(
                  onTap: () => setState(() => _avatarId = avatarId),
                  borderRadius: BorderRadius.circular(40),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text(
                      '$number',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
