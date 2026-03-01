import 'package:flutter/material.dart';
import 'package:kahu_ola/core/services/push_notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  final Map<String, bool> _preferences = {
    'Maui': true,
    'Lanai': true,
    'Molokai': true,
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final savedPreferences =
        await PushNotificationService.loadIslandPreferences();
    if (!mounted) return;

    setState(() {
      _preferences
        ..clear()
        ..addAll(savedPreferences);
      _isLoading = false;
    });
  }

  Future<void> _updatePreference(String island, bool enabled) async {
    setState(() {
      _preferences[island] = enabled;
    });

    await PushNotificationService.setIslandPreference(island, enabled);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? '$island alerts enabled for this device.'
              : '$island alerts disabled for this device.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Public Fire Alerts',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose which island alerts this phone should receive. '
                  'Each toggle updates the Firebase topic subscription for '
                  'this device.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: _preferences.entries.map((entry) {
                      return SwitchListTile(
                        title: Text('${entry.key} alerts'),
                        subtitle: Text(
                          'Receive public wildfire alerts for ${entry.key}.',
                        ),
                        value: entry.value,
                        onChanged: (enabled) =>
                            _updatePreference(entry.key, enabled),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Firebase setup note: install the Android and iOS '
                      'Firebase configuration files before testing push '
                      'notifications on a real device.',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
