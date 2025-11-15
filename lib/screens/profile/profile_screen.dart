import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// -------------------------
// Models
// -------------------------
class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime joinedDate;

  UserProfile({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.joinedDate,
  });
}

class SyncStatus {
  final bool isSynced;
  final DateTime lastSync;
  final bool isSyncing;

  SyncStatus({
    required this.isSynced,
    required this.lastSync,
    this.isSyncing = false,
  });

  SyncStatus copyWith({bool? isSynced, DateTime? lastSync, bool? isSyncing}) {
    return SyncStatus(
      isSynced: isSynced ?? this.isSynced,
      lastSync: lastSync ?? this.lastSync,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class StorageInfo {
  final double usedMB;
  final double totalMB;

  StorageInfo({required this.usedMB, required this.totalMB});

  double get percent => (totalMB <= 0) ? 0 : (usedMB / totalMB).clamp(0.0, 1.0);
}

class Connections {
  final bool googleConnected;
  final bool githubConnected;
  final bool appleConnected;

  Connections({
    required this.googleConnected,
    required this.githubConnected,
    required this.appleConnected,
  });

  Connections copyWith({
    bool? googleConnected,
    bool? githubConnected,
    bool? appleConnected,
  }) {
    return Connections(
      googleConnected: googleConnected ?? this.googleConnected,
      githubConnected: githubConnected ?? this.githubConnected,
      appleConnected: appleConnected ?? this.appleConnected,
    );
  }
}

class Preferences {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool productivityTipsEnabled;

  Preferences({
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.productivityTipsEnabled,
  });

  Preferences copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? productivityTipsEnabled,
  }) {
    return Preferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      productivityTipsEnabled:
          productivityTipsEnabled ?? this.productivityTipsEnabled,
    );
  }
}

// -------------------------
// Providers
// All providers live in this file per requirements
// -------------------------

// 1) profileProvider: mock user
final profileProvider = Provider<UserProfile>((ref) {
  return UserProfile(
    name: 'Alex Morgan',
    email: 'alex.morgan@example.com',
    avatarUrl: '', // empty => placeholder
    joinedDate: DateTime(2025, 4, 12),
  );
});

// 2) syncStatusProvider & 3) syncControllerProvider
class SyncController extends StateNotifier<SyncStatus> {
  SyncController()
    : super(
        SyncStatus(
          isSynced: true,
          lastSync: DateTime.now().subtract(const Duration(hours: 4)),
          isSyncing: false,
        ),
      );

  void toggleSync() {
    state = state.copyWith(isSynced: !state.isSynced);
  }

  Future<void> syncNow() async {
    state = state.copyWith(isSyncing: true);
    await Future.delayed(const Duration(seconds: 2));
    state = SyncStatus(
      isSynced: true,
      lastSync: DateTime.now(),
      isSyncing: false,
    );
  }
}

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncStatus>(
      (ref) => SyncController(),
    );

// 4) storageProvider
final storageProvider = StateProvider<StorageInfo>((ref) {
  // mock: 42 MB used of 2048 (2 GB)
  return StorageInfo(usedMB: 42.0, totalMB: 2048.0);
});

// 5) connectionsProvider
class ConnectionsController extends StateNotifier<Connections> {
  ConnectionsController()
    : super(
        Connections(
          googleConnected: true,
          githubConnected: false,
          appleConnected: false,
        ),
      );

  Future<void> connect(String provider) async {
    // mock delay
    await Future.delayed(const Duration(milliseconds: 800));
    switch (provider) {
      case 'google':
        state = state.copyWith(googleConnected: true);
        break;
      case 'github':
        state = state.copyWith(githubConnected: true);
        break;
      case 'apple':
        state = state.copyWith(appleConnected: true);
        break;
    }
  }

  void disconnect(String provider) {
    switch (provider) {
      case 'google':
        state = state.copyWith(googleConnected: false);
        break;
      case 'github':
        state = state.copyWith(githubConnected: false);
        break;
      case 'apple':
        state = state.copyWith(appleConnected: false);
        break;
    }
  }
}

final connectionsProvider =
    StateNotifierProvider<ConnectionsController, Connections>(
      (ref) => ConnectionsController(),
    );

// 6) preferencesProvider
class PreferencesController extends StateNotifier<Preferences> {
  PreferencesController()
    : super(
        Preferences(
          notificationsEnabled: true,
          darkModeEnabled: false,
          productivityTipsEnabled: true,
        ),
      );

  void toggleNotifications() =>
      state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  void toggleDarkMode() =>
      state = state.copyWith(darkModeEnabled: !state.darkModeEnabled);
  void toggleTips() => state = state.copyWith(
    productivityTipsEnabled: !state.productivityTipsEnabled,
  );
}

final preferencesProvider =
    StateNotifierProvider<PreferencesController, Preferences>(
      (ref) => PreferencesController(),
    );

// -------------------------
// Widgets: ProfileScreen
// -------------------------

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  String _monthYear(DateTime d) {
    final month = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][d.month - 1];
    return '$month ${d.year}';
  }

  Future<void> _showEditProfileModal(BuildContext context) async {
    final user = ref.read(profileProvider);
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // mock: update profile provider isn't required by requirement but we keep this modal as mock
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showChangePhoto(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Photo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profileProvider);
    final sync = ref.watch(syncControllerProvider);
    final storage = ref.watch(storageProvider);
    final connections = ref.watch(connectionsProvider);
    final prefs = ref.watch(preferencesProvider);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showEditProfileModal(context),
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit profile',
                      ),
                      IconButton(
                        onPressed: () => debugPrint('Open settings (debug)'),
                        icon: const Icon(Icons.settings_outlined),
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // USER INFO CARD
              Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 680),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.12),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _showChangePhoto(context),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.grey.shade200,
                          child: user.avatarUrl.isEmpty
                              ? Text(
                                  _initials(user.name),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Taskify User',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: Colors.grey.withValues(alpha: 0.08),
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Joined ${_monthYear(user.joinedDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // SYNC STATUS CARD
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 680),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.12),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.cloud_outlined,
                        size: 28,
                        color: Color(0xFF6C6CE5),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cloud Sync',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Last sync: ${_friendlyTime(sync.lastSync)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Switch(
                              value: sync.isSynced,
                              onChanged: (v) => ref
                                  .read(syncControllerProvider.notifier)
                                  .toggleSync(),
                              trackColor: WidgetStateProperty.resolveWith(
                                (states) => const Color(0xFFBEE6FF),
                              ),
                              thumbColor: WidgetStateProperty.resolveWith(
                                (states) => sync.isSynced
                                    ? const Color(0xFF2196F3)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        sync.isSyncing
                            ? const SizedBox(
                                height: 28,
                                width: 96,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: () => ref
                                    .read(syncControllerProvider.notifier)
                                    .syncNow(),
                                child: const Text('Sync Now'),
                              ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // STORAGE USAGE CARD
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 680),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.12),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.sd_storage_outlined,
                              size: 22,
                              color: Color(0xFF8E8EF4),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Storage Usage',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Used: ${storage.usedMB.toStringAsFixed(0)} MB of ${storage.totalMB ~/ 1024} GB',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // animated bar
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final percent = storage.percent;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 10,
                            color: Colors.grey.withValues(alpha: 0.06),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: percent),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, child) {
                                return FractionallySizedBox(
                                  widthFactor: value,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    color: const Color(0xFFB2DFFC),
                                    height: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Attachments, notes, and metadata',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CONNECTED ACCOUNTS
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 680),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.12),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Text(
                        'Connected Accounts',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF5F5F5)),
                    _accountRow(
                      context: context,
                      title: 'Google',
                      icon: Icons.g_mobiledata,
                      connected: connections.googleConnected,
                      onConnect: () => ref
                          .read(connectionsProvider.notifier)
                          .connect('google'),
                      onDisconnect: () => ref
                          .read(connectionsProvider.notifier)
                          .disconnect('google'),
                    ),
                    _accountRow(
                      context: context,
                      title: 'GitHub',
                      icon: Icons.code,
                      connected: connections.githubConnected,
                      onConnect: () => ref
                          .read(connectionsProvider.notifier)
                          .connect('github'),
                      onDisconnect: () => ref
                          .read(connectionsProvider.notifier)
                          .disconnect('github'),
                    ),
                    _accountRow(
                      context: context,
                      title: 'Apple',
                      icon: Icons.apple,
                      connected: connections.appleConnected,
                      onConnect: () => ref
                          .read(connectionsProvider.notifier)
                          .connect('apple'),
                      onDisconnect: () => ref
                          .read(connectionsProvider.notifier)
                          .disconnect('apple'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PREFERENCES
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 680),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.12),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Text(
                        'Preferences',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF5F5F5)),
                    _preferenceRow(
                      context: context,
                      label: 'Notifications',
                      value: prefs.notificationsEnabled,
                      onChanged: () => ref
                          .read(preferencesProvider.notifier)
                          .toggleNotifications(),
                    ),
                    _preferenceRow(
                      context: context,
                      label: 'Dark Mode',
                      value: prefs.darkModeEnabled,
                      onChanged: () => ref
                          .read(preferencesProvider.notifier)
                          .toggleDarkMode(),
                    ),
                    _preferenceRow(
                      context: context,
                      label: 'Productivity Tips',
                      value: prefs.productivityTipsEnabled,
                      onChanged: () =>
                          ref.read(preferencesProvider.notifier).toggleTips(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // LOGOUT
              Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 680),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: TextButton(
                    onPressed: () => debugPrint('User logged out'),
                    child: Text(
                      'Log Out',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFE53935),
                        fontWeight: FontWeight.w700,
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

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String _friendlyTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  Widget _accountRow({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool connected,
    required VoidCallback onConnect,
    required VoidCallback onDisconnect,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: 8),
          connected
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Connected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                )
              : Text(
                  'Not connected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
          const SizedBox(width: 12),
          connected
              ? TextButton(
                  onPressed: onDisconnect,
                  child: const Text('Disconnect'),
                )
              : OutlinedButton(
                  onPressed: onConnect,
                  child: const Text('Connect'),
                ),
        ],
      ),
    );
  }

  Widget _preferenceRow({
    required BuildContext context,
    required String label,
    required bool value,
    required VoidCallback onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Switch(value: value, onChanged: (_) => onChanged()),
        ],
      ),
    );
  }
}
