import 'package:flutter/material.dart';

import '../data/profile_repository.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({
    super.key,
    required this.uid,
    required this.profileRepository,
  });

  final String uid;
  final ProfileRepository profileRepository;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  bool _saving = false;
  String _avatarId = 'default_01';
  String? _error;

  static const _avatars = <String>[
    'default_01',
    'default_02',
    'default_03',
    'default_04',
  ];

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
      await widget.profileRepository.createProfile(
        uid: widget.uid,
        gameName: _nameController.text,
        avatarId: _avatarId,
      );
    } on ArgumentError catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message?.toString());
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not create your profile. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose your player name',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                maxLength: 20,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: '3–20 characters',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 18),
              Text(
                'Choose an avatar',
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
              const Spacer(),
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
                child: Text(_saving ? 'Saving...' : 'Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
