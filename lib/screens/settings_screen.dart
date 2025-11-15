import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// -------------------------
// Models & Providers (in-file)
// -------------------------

enum AppTheme { light, dark, system }

class NotificationSettings {
  final bool notificationsEnabled;
  final bool taskDueAlerts;
  final bool habitReminders;
  final TimeOfDay? dailyReminder;

  NotificationSettings({
    required this.notificationsEnabled,
    required this.taskDueAlerts,
    required this.habitReminders,
    this.dailyReminder,
  });

  NotificationSettings copyWith({
    bool? notificationsEnabled,
    bool? taskDueAlerts,
    bool? habitReminders,
    TimeOfDay? dailyReminder,
  }) {
    return NotificationSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      taskDueAlerts: taskDueAlerts ?? this.taskDueAlerts,
      habitReminders: habitReminders ?? this.habitReminders,
      dailyReminder: dailyReminder ?? this.dailyReminder,
    );
  }
}

class SyncState {
  final DateTime lastSynced;
  final bool isSyncing;

  SyncState({required this.lastSynced, required this.isSyncing});

  SyncState copyWith({DateTime? lastSynced, bool? isSyncing}) {
    return SyncState(
      lastSynced: lastSynced ?? this.lastSynced,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

// themeProvider
final themeProvider = StateProvider<AppTheme>((ref) => AppTheme.system);

// notifications provider
final settingsNotificationsProvider =
    StateNotifierProvider<NotificationController, NotificationSettings>((ref) {
      return NotificationController();
    });

class NotificationController extends StateNotifier<NotificationSettings> {
  NotificationController()
    : super(
        NotificationSettings(
          notificationsEnabled: true,
          taskDueAlerts: true,
          habitReminders: true,
          dailyReminder: const TimeOfDay(hour: 8, minute: 0),
        ),
      );

  void toggleNotifications() =>
      state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  void toggleTaskDueAlerts() =>
      state = state.copyWith(taskDueAlerts: !state.taskDueAlerts);
  void toggleHabitReminders() =>
      state = state.copyWith(habitReminders: !state.habitReminders);
  void setDailyReminder(TimeOfDay t) =>
      state = state.copyWith(dailyReminder: t);
}

// sync provider
final settingsSyncProvider =
    StateNotifierProvider<SettingsSyncController, SyncState>((ref) {
      return SettingsSyncController();
    });

class SettingsSyncController extends StateNotifier<SyncState> {
  SettingsSyncController()
    : super(
        SyncState(
          lastSynced: DateTime.now().subtract(const Duration(hours: 2)),
          isSyncing: false,
        ),
      );

  Future<void> syncNow() async {
    state = state.copyWith(isSyncing: true);
    await Future.delayed(const Duration(seconds: 1));
    state = SyncState(lastSynced: DateTime.now(), isSyncing: false);
  }

  Future<void> backupNow() async {
    state = state.copyWith(isSyncing: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(lastSynced: DateTime.now(), isSyncing: false);
  }

  Future<void> restoreNow() async {
    state = state.copyWith(isSyncing: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isSyncing: false);
  }
}

// auth controller (mock)
final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(),
);

class AuthController {
  void logout() => debugPrint('authController: logout() called');
}

// -------------------------
// SettingsScreen UI
// -------------------------

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final notifications = ref.watch(settingsNotificationsProvider);
    final sync = ref.watch(settingsSyncProvider);

    final themeCtrl = ref.read(themeProvider.notifier);
    final notifCtrl = ref.read(settingsNotificationsProvider.notifier);
    final syncCtrl = ref.read(settingsSyncProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER (hero)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.85 * 255).round()),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      child: Text(
                        'T',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Tweak how Taskify works — sync, notifications, and appearance",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => debugPrint('Settings info (debug)'),
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // ACCOUNT SECTION
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                            'AM',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alex Morgan',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'alex.morgan@example.com',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => debugPrint('Manage Profile (mock)'),
                          child: const Text('Manage Profile'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // APPEARANCE
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _themeModeRow(
                      context,
                      theme,
                      (AppTheme t) => themeCtrl.state = t,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Accent',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // NOTIFICATIONS
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _toggleRow(
                      label: 'Enable Notifications',
                      value: notifications.notificationsEnabled,
                      onChanged: () => notifCtrl.toggleNotifications(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Daily Reminder',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        notifications.dailyReminder?.format(context) ??
                            'Not set',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: OutlinedButton(
                        onPressed: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime:
                                notifications.dailyReminder ??
                                const TimeOfDay(hour: 8, minute: 0),
                          );
                          if (t != null) notifCtrl.setDailyReminder(t);
                        },
                        child: const Text('Set'),
                      ),
                    ),
                    const Divider(height: 1),
                    _toggleRow(
                      label: 'Task Due Alerts',
                      value: notifications.taskDueAlerts,
                      onChanged: () => notifCtrl.toggleTaskDueAlerts(),
                    ),
                    const Divider(height: 1),
                    _toggleRow(
                      label: 'Habit Reminder',
                      value: notifications.habitReminders,
                      onChanged: () => notifCtrl.toggleHabitReminders(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // DATA & SYNC
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data & Sync',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Last Synced',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          _friendlyTime(sync.lastSynced),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: () => syncCtrl.syncNow(),
                                child: const Text('Sync to Cloud'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => syncCtrl.backupNow(),
                              child: const Text('Backup Now'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton(
                            onPressed: () => syncCtrl.restoreNow(),
                            child: const Text('Restore'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PRIVACY & SECURITY
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy & Security',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _toggleRow(
                      label: 'App Lock',
                      value: false,
                      onChanged: () => debugPrint('toggle App Lock (mock)'),
                    ),
                    const Divider(height: 1),
                    _toggleRow(
                      label: 'Biometric Unlock',
                      value: false,
                      onChanged: () => debugPrint('toggle Biometric (mock)'),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: TextButton(
                        onPressed: () => debugPrint('Clear Local Data (mock)'),
                        child: Text(
                          'Clear Local Data',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFFE53935)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ABOUT
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Taskify',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Version',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: Text(
                        '1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      onTap: () => debugPrint('Licenses (mock)'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Licenses',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      onTap: () => debugPrint('Rate the App (mock)'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Rate the App',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      onTap: () => debugPrint('Contact Support (mock)'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Contact Support',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // LOGOUT
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE),
                        foregroundColor: const Color(0xFFC62828),
                        side: const BorderSide(color: Color(0xFFE53935)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Log Out'),
                            content: const Text(
                              'Are you sure you want to log out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text('Log Out'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          ref.read(authControllerProvider).logout();
                        }
                      },
                      child: Text(
                        'Log Out',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFC62828),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _toggleRow({
    required String label,
    required bool value,
    required VoidCallback onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Switch.adaptive(value: value, onChanged: (_) => onChanged()),
        ],
      ),
    );
  }

  Widget _themeModeRow(
    BuildContext context,
    AppTheme selected,
    ValueChanged<AppTheme> onChange,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SegmentedButton<AppTheme>(
        segments: const <ButtonSegment<AppTheme>>[
          ButtonSegment<AppTheme>(value: AppTheme.light, label: Text('Light')),
          ButtonSegment<AppTheme>(value: AppTheme.dark, label: Text('Dark')),
          ButtonSegment<AppTheme>(
            value: AppTheme.system,
            label: Text('System'),
          ),
        ],
        selected: <AppTheme>{selected},
        onSelectionChanged: (Set<AppTheme> newSelection) =>
            onChange(newSelection.first),
      ),
    );
  }

  String _friendlyTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
