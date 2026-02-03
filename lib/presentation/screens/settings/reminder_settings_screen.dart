import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/reminder_settings.dart';
import '../../providers/providers.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState
    extends ConsumerState<ReminderSettingsScreen> {
  late ReminderSettings _settings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userSettings = ref.read(settingsProvider);
    if (userSettings.reminderSettingsJson != null) {
      _settings = ReminderSettings.fromJson(userSettings.reminderSettingsJson!);
    } else {
      _settings = ReminderSettings.defaultSettings;
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationService = ref.read(notificationServiceProvider);

      if (_settings.enabled) {
        final granted = await notificationService.requestPermissions();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification permission denied'),
              ),
            );
          }
          setState(() {
            _settings = _settings.copyWith(enabled: false);
            _isLoading = false;
          });
          return;
        }
      }

      await ref
          .read(settingsProvider.notifier)
          .setReminderSettings(_settings.toJson());
      await notificationService.scheduleReminders(_settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _settings.enabled
                  ? 'Reminders scheduled for ${_settings.formattedTime}'
                  : 'Reminders disabled',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save reminder settings: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _settings.hour, minute: _settings.minute),
    );

    if (picked != null) {
      setState(() {
        _settings = _settings.copyWith(
          hour: picked.hour,
          minute: picked.minute,
        );
      });
    }
  }

  void _toggleDay(int day) {
    final newDays = Set<int>.from(_settings.daysOfWeek);
    if (newDays.contains(day)) {
      if (newDays.length > 1) {
        newDays.remove(day);
      }
    } else {
      newDays.add(day);
    }
    setState(() {
      _settings = _settings.copyWith(daysOfWeek: newDays);
    });
  }

  void _setPreset(Set<int> days) {
    setState(() {
      _settings = _settings.copyWith(daysOfWeek: days);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Daily Reminders'),
            subtitle: Text(
              _settings.enabled
                  ? 'Reminder at ${_settings.formattedTime}'
                  : 'Disabled',
            ),
            value: _settings.enabled,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(enabled: value);
              });
            },
          ),
          const Divider(),
          if (_settings.enabled) ...[
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Reminder Time'),
              subtitle: Text(_settings.formattedTime),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),
            Text(
              'Days',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Every day'),
                  onPressed: () => _setPreset({1, 2, 3, 4, 5, 6, 7}),
                  backgroundColor: _settings.daysOfWeek.length == 7
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                ),
                ActionChip(
                  label: const Text('Weekdays'),
                  onPressed: () => _setPreset({1, 2, 3, 4, 5}),
                  backgroundColor:
                      _settings.daysOfWeek.containsAll({1, 2, 3, 4, 5}) &&
                              _settings.daysOfWeek.length == 5
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                ),
                ActionChip(
                  label: const Text('Weekends'),
                  onPressed: () => _setPreset({6, 7}),
                  backgroundColor:
                      _settings.daysOfWeek.containsAll({6, 7}) &&
                              _settings.daysOfWeek.length == 2
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final day = index + 1;
                final isSelected = _settings.daysOfWeek.contains(day);
                return GestureDetector(
                  onTap: () => _toggleDay(day),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayNames[index][0],
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _settings.daysDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
          FilledButton(
            onPressed: _isLoading ? null : _saveSettings,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
