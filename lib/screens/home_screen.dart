import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Models
class Task {
  final String id;
  final String title;
  final String category;
  final String priority;
  final String time;
  bool completed;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.time,
    this.completed = false,
  });

  Task copyWith({bool? completed}) {
    return Task(
      id: id,
      title: title,
      category: category,
      priority: priority,
      time: time,
      completed: completed ?? this.completed,
    );
  }
}

class Habit {
  final String id;
  final String name;
  int streak;
  bool doneToday;

  Habit({
    required this.id,
    required this.name,
    required this.streak,
    this.doneToday = false,
  });

  Habit copyWith({int? streak, bool? doneToday}) {
    return Habit(
      id: id,
      name: name,
      streak: streak ?? this.streak,
      doneToday: doneToday ?? this.doneToday,
    );
  }
}

class DashboardStats {
  final int completedToday;
  final int dueToday;
  final int streak;

  DashboardStats({
    required this.completedToday,
    required this.dueToday,
    required this.streak,
  });
}

// Riverpod Providers
final dashboardStatsProvider = StateProvider<DashboardStats>((ref) {
  return DashboardStats(completedToday: 7, dueToday: 5, streak: 12);
});

final todayTasksProvider = StateProvider<List<Task>>((ref) {
  return [
    Task(
      id: '1',
      title: 'Finish design mockups',
      category: 'Design',
      priority: 'High',
      time: '2:00 PM',
      completed: false,
    ),
    Task(
      id: '2',
      title: 'Review pull requests',
      category: 'Code',
      priority: 'Medium',
      time: '3:30 PM',
      completed: false,
    ),
    Task(
      id: '3',
      title: 'Update documentation',
      category: 'Docs',
      priority: 'Low',
      time: '4:00 PM',
      completed: false,
    ),
    Task(
      id: '4',
      title: 'Team standup meeting',
      category: 'Meeting',
      priority: 'High',
      time: '10:00 AM',
      completed: false,
    ),
    Task(
      id: '5',
      title: 'Deploy to staging',
      category: 'Deployment',
      priority: 'High',
      time: '5:00 PM',
      completed: false,
    ),
  ];
});

final habitsProvider = StateProvider<List<Habit>>((ref) {
  return [
    Habit(id: '1', name: 'Exercise', streak: 23, doneToday: false),
    Habit(id: '2', name: 'Reading', streak: 15, doneToday: false),
    Habit(id: '3', name: 'Meditation', streak: 8, doneToday: false),
    Habit(id: '4', name: 'Writing', streak: 5, doneToday: false),
  ];
});

final insightsMockProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'weeklyData': [12, 19, 8, 24, 18, 15, 22],
    'categories': {'Work': 35, 'Personal': 30, 'Health': 20, 'Other': 15},
  };
});

final showFabProvider = StateProvider<bool>((ref) => true);

// Widgets
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showFab =
        _scrollController.position.userScrollDirection ==
        ScrollDirection.forward;
    ref.read(showFabProvider.notifier).state = showFab;
  }

  @override
  Widget build(BuildContext context) {
    final showFab = ref.watch(showFabProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar (polished hero header)
          SliverAppBar(
            pinned: true,
            elevation: 0,
            expandedHeight: 240,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF6C6CE5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 16),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Taskify',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.18,
                            ),
                            child: Text(
                              'VG',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your productivity, simplified',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      // Search field
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.white70),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Search tasks, projects, or people',
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (q) => debugPrint('Search: $q'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              // Greeting Section with Fade Animation
              FadeTransition(
                opacity: _fadeController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning!',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Here's your productivity overview",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // KPI Stats Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: _buildKPIStatsRow(context, ref),
              ),
              // Today's Tasks Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: _buildTodayTasksSection(context, ref),
              ),
              // Productivity Snapshot
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: _buildProductivitySnapshot(context),
              ),
              // Habits Summary
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: _buildHabitsSummary(context, ref),
              ),
              // Quick Navigation Links
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: _buildQuickNavigation(context),
              ),
              // Footer Spacing
              const SizedBox(height: 120),
            ]),
          ),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: showFab ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: showFab ? 1 : 0,
          child: _buildQuickAddButton(context, ref),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildKPIStatsRow(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    return Row(
      children: [
        Expanded(
          child: _KPICard(
            title: 'Completed',
            subtitle: 'tasks completed today',
            value: stats.completedToday.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: () => debugPrint('KPI: Completed tapped'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KPICard(
            title: 'Pending',
            subtitle: 'tasks in progress',
            value: stats.dueToday.toString(),
            icon: Icons.timelapse,
            color: Colors.blue,
            onTap: () => debugPrint('KPI: Pending tapped'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KPICard(
            title: 'Overdue',
            subtitle: 'tasks need attention',
            value: '3',
            icon: Icons.error_outline,
            color: Colors.orange,
            onTap: () => debugPrint('KPI: Overdue tapped'),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTasksSection(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todayTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Tasks",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  "Focus on what matters most",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => debugPrint('See All Tasks tapped'),
              child: Text(
                'See All →',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Card wrapper for tasks
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: tasks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No tasks for today!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: tasks.take(5).map((task) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: _TaskCard(
                        task: task,
                        onSwipe: () {
                          ref.read(todayTasksProvider.notifier).state = tasks
                              .where((t) => t.id != task.id)
                              .toList();
                        },
                        onLongPress: () =>
                            debugPrint('Task Detail: ${task.title}'),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildProductivitySnapshot(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productivity Snapshot',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ChartPreviewCard(
                title: 'Weekly Progress',
                icon: Icons.trending_up_outlined,
                onTap: () => debugPrint('Open Weekly Insights'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChartPreviewCard(
                title: 'Categories',
                icon: Icons.pie_chart_outline,
                onTap: () => debugPrint('Open Category Insights'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHabitsSummary(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habits',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: habits
                .map(
                  (habit) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _HabitChip(
                      habit: habit,
                      onTap: () {
                        final updated = habit.copyWith(
                          doneToday: !habit.doneToday,
                          streak: habit.doneToday
                              ? habit.streak
                              : habit.streak + 1,
                        );
                        ref.read(habitsProvider.notifier).state = habits
                            .map((h) => h.id == habit.id ? updated : h)
                            .toList();
                      },
                      onLongPress: () =>
                          debugPrint('Habit Detail: ${habit.name}'),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showQuickAddModal(context, ref),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((0.85 * 255).round()),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((0.28 * 255).round()),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Quick Add Task',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickAddModal(BuildContext context, WidgetRef ref) {
    String title = '';
    String priority = 'Medium';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Add Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Task title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      value: priority,
                      isExpanded: true,
                      items: ['Low', 'Medium', 'High']
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => priority = value ?? 'Medium'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (title.isNotEmpty) {
                          final newTask = Task(
                            id: DateTime.now().toString(),
                            title: title,
                            category: 'Quick Add',
                            priority: priority,
                            time: 'Now',
                          );
                          final tasks = ref.read(todayTasksProvider);
                          ref.read(todayTasksProvider.notifier).state = [
                            ...tasks,
                            newTask,
                          ];
                          Navigator.pop(context);
                          debugPrint('Task added: $title');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Add Task'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Reusable Components
class _KPICard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final String? subtitle;
  final Color? color;

  const _KPICard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.color,
  });

  @override
  State<_KPICard> createState() => _KPICardState();
}

class _KPICardState extends State<_KPICard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.97).animate(_controller),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          (widget.color ??
                                  Theme.of(context).colorScheme.primary)
                              .withAlpha((0.12 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 16,
                      color:
                          widget.color ?? Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                widget.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onSwipe;
  final VoidCallback onLongPress;

  const _TaskCard({
    required this.task,
    required this.onSwipe,
    required this.onLongPress,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onSwipe(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.check_circle, color: Colors.green.shade700),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            task.category,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.blue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: _getPriorityColor(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          task.time,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartPreviewCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ChartPreviewCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildQuickNavigation(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quick Links',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/profile'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.12),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 24,
                      color: const Color(0xFF6C6CE5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/settings'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.12),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 24,
                      color: const Color(0xFF8E8EF4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Preferences',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _HabitChip extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _HabitChip({
    required this.habit,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: habit.doneToday
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: habit.doneToday
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: (habit.streak % 7) / 7,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        habit.doneToday ? Colors.green : Colors.blue,
                      ),
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                  Text(
                    '${habit.streak}d',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              habit.name,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
