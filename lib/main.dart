import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/planner_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/task_create/task_create_screen.dart';
import 'screens/task_detail/task_detail_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  runApp(const ProviderScope(child: TaskifyApp()));
}

class TaskifyApp extends ConsumerWidget {
  const TaskifyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Taskify',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: ThemeMode.system,
      onGenerateRoute: _onGenerateRoute,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/planner': (context) => const PlannerScreen(),
        '/tasks': (context) => const TasksScreen(),
        '/task-create': (context) => const TaskCreateScreen(),
        '/habits': (context) => const HabitsScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }

  static Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name?.startsWith('/task/') ?? false) {
      final taskId = settings.name!.split('/').last;
      return MaterialPageRoute(
        builder: (context) => TaskDetailScreen(taskId: taskId),
        settings: settings,
      );
    }
    return null;
  }

  static ThemeData _lightTheme() {
    final primary = const Color(0xFF2563EB); // refined blue
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFFF6F9FC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      textTheme: ThemeData.light().textTheme.copyWith(
        headlineSmall: ThemeData.light().textTheme.headlineSmall?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: ThemeData.light().textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        labelLarge: ThemeData.light().textTheme.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        shadowColor: Colors.black12,
      ),
    );
  }

  static ThemeData _darkTheme() {
    final primary = const Color(0xFF3B82F6);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFF0B1020),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
      textTheme: ThemeData.dark().textTheme.copyWith(
        headlineSmall: ThemeData.dark().textTheme.headlineSmall?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: ThemeData.dark().textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        color: const Color(0xFF0F1724),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        shadowColor: Colors.black45,
      ),
    );
  }
}
