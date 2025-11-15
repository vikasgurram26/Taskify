import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Models
class Habit {
  final String id;
  final String name;
  final String frequency;
  final int streak;
  final List<bool> weeklyStatus;
  final bool doneToday;

  Habit({
    required this.id,
    required this.name,
    required this.frequency,
    required this.streak,
    required this.weeklyStatus,
    required this.doneToday,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? frequency,
    int? streak,
    List<bool>? weeklyStatus,
    bool? doneToday,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      streak: streak ?? this.streak,
      weeklyStatus: weeklyStatus ?? this.weeklyStatus,
      doneToday: doneToday ?? this.doneToday,
    );
  }
}

/// Mock Data
final List<Habit> mockHabits = [
  Habit(
    id: '1',
    name: 'Morning Meditation',
    frequency: 'Daily',
    streak: 12,
    weeklyStatus: [true, true, false, true, true, true, true],
    doneToday: true,
  ),
  Habit(
    id: '2',
    name: 'Exercise',
    frequency: '5× Weekly',
    streak: 8,
    weeklyStatus: [true, false, true, true, true, false, true],
    doneToday: false,
  ),
  Habit(
    id: '3',
    name: 'Read 20 Pages',
    frequency: 'Daily',
    streak: 24,
    weeklyStatus: [true, true, true, true, true, true, true],
    doneToday: true,
  ),
  Habit(
    id: '4',
    name: 'Journaling',
    frequency: '3× Weekly',
    streak: 5,
    weeklyStatus: [false, true, false, true, false, true, false],
    doneToday: true,
  ),
  Habit(
    id: '5',
    name: 'Drink 8 Glasses Water',
    frequency: 'Daily',
    streak: 3,
    weeklyStatus: [true, true, true, false, false, false, false],
    doneToday: false,
  ),
];

final List<String> motivationalMessages = [
  'Consistency compounds.',
  'Small steps lead to big changes.',
  'You\'re closer than yesterday.',
  'Progress over perfection.',
  'Habits make the person.',
  'Every day is a fresh start.',
  'You\'ve got this!',
];

/// Providers
final habitsProvider = StateProvider<List<Habit>>((ref) {
  return mockHabits;
});

final motivationProvider = StateProvider<String>((ref) {
  final index = DateTime.now().day % motivationalMessages.length;
  return motivationalMessages[index];
});

final showHabitsFabProvider = StateProvider<bool>((ref) {
  return true;
});

final habitControllerProvider = StateNotifierProvider<HabitController, void>((
  ref,
) {
  return HabitController(ref);
});

class HabitController extends StateNotifier<void> {
  final Ref ref;

  HabitController(this.ref) : super(null);

  void markDoneToday(String habitId) {
    final habits = ref.read(habitsProvider);
    final index = habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final habit = habits[index];
      if (!habit.doneToday) {
        final newWeeklyStatus = List<bool>.from(habit.weeklyStatus);
        newWeeklyStatus[DateTime.now().weekday - 1] = true;
        final updatedHabit = habit.copyWith(
          doneToday: true,
          streak: habit.streak + 1,
          weeklyStatus: newWeeklyStatus,
        );
        final updatedHabits = [...habits];
        updatedHabits[index] = updatedHabit;
        ref.read(habitsProvider.notifier).state = updatedHabits;
        debugPrint('Habit marked done: ${habit.name}');
      }
    }
  }

  void skipToday(String habitId) {
    final habits = ref.read(habitsProvider);
    final index = habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final habit = habits[index];
      final updatedHabit = habit.copyWith(streak: 0);
      final updatedHabits = [...habits];
      updatedHabits[index] = updatedHabit;
      ref.read(habitsProvider.notifier).state = updatedHabits;
      debugPrint('Habit skipped: ${habit.name}');
    }
  }

  void deleteHabit(String habitId) {
    final habits = ref.read(habitsProvider);
    final updatedHabits = habits.where((h) => h.id != habitId).toList();
    ref.read(habitsProvider.notifier).state = updatedHabits;
    debugPrint('Habit deleted: $habitId');
  }

  void updateHabit(Habit habit) {
    final habits = ref.read(habitsProvider);
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      final updatedHabits = [...habits];
      updatedHabits[index] = habit;
      ref.read(habitsProvider.notifier).state = updatedHabits;
      debugPrint('Habit updated: ${habit.name}');
    }
  }

  void createHabit(String name, String frequency) {
    final habits = ref.read(habitsProvider);
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      frequency: frequency,
      streak: 0,
      weeklyStatus: [false, false, false, false, false, false, false],
      doneToday: false,
    );
    ref.read(habitsProvider.notifier).state = [...habits, newHabit];
    debugPrint('Habit created: $name');
  }
}

/// Main Screen
class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen>
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
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final showFab = _scrollController.offset < 100;
    ref.read(showHabitsFabProvider.notifier).state = showFab;
  }

  void _openCreateHabitModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _CreateHabitModal(),
    );
  }

  void _openHabitDetailModal(Habit habit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _HabitDetailModal(habit: habit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final showFab = ref.watch(showHabitsFabProvider);
    final motivation = ref.watch(motivationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          /// Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Habits',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          debugPrint('Open habits stats');
                        },
                        icon: const Icon(Icons.bar_chart, size: 20),
                        splashRadius: 24,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _openCreateHabitModal,
                        icon: const Icon(Icons.add, size: 20),
                        splashRadius: 24,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// Motivational Banner
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _fadeController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    motivation,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Weekly Overview Strip
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (index) {
                      final dayNames = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ];
                      final dayIndex = (DateTime.now().weekday - 1 + index) % 7;
                      final completedCount = habits.fold<int>(0, (sum, habit) {
                        return sum + (habit.weeklyStatus[dayIndex] ? 1 : 0);
                      });
                      final totalHabits = habits.length;
                      final isCompleted =
                          completedCount == totalHabits && totalHabits > 0;

                      return GestureDetector(
                        onTap: () {
                          debugPrint('Selected ${dayNames[dayIndex]}');
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Colors.green.shade500
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isCompleted
                                        ? Colors.green.shade500
                                        : Colors.grey.withValues(alpha: 0.2),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dayNames[dayIndex],
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          /// Habits List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: habits.map((habit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _HabitCard(
                      habit: habit,
                      onTapProgress: () {
                        ref.read(habitControllerProvider);
                        ref
                            .read(habitControllerProvider.notifier)
                            .markDoneToday(habit.id);
                      },
                      onLongPress: () => _openHabitDetailModal(habit),
                      onSwipeLeft: () {
                        ref
                            .read(habitControllerProvider.notifier)
                            .deleteHabit(habit.id);
                      },
                      onSwipeRight: () {
                        ref
                            .read(habitControllerProvider.notifier)
                            .skipToday(habit.id);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          /// Bottom spacing
          SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        offset: showFab ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 300),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
          ),
          child: FloatingActionButton.extended(
            onPressed: _openCreateHabitModal,
            label: const Text('Add Habit'),
            icon: const Icon(Icons.add),
            elevation: 0,
            backgroundColor: Colors.blue.shade500,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Habit Card Widget
class _HabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  final VoidCallback onTapProgress;
  final VoidCallback onLongPress;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const _HabitCard({
    required this.habit,
    required this.onTapProgress,
    required this.onLongPress,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  ConsumerState<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<_HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _streakPulseController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _streakPulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ringController.dispose();
    _streakPulseController.dispose();
    super.dispose();
  }

  void _handleProgressTap() {
    _ringController.forward(from: 0);
    widget.onTapProgress();
  }

  @override
  Widget build(BuildContext context) {
    final fillPercentage = widget.habit.doneToday ? 1.0 : 0.0;

    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Dismissible(
        key: Key(widget.habit.id),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            widget.onSwipeRight();
          } else {
            widget.onSwipeLeft();
          }
        },
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade500,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: Colors.amber.shade500,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(Icons.skip_next, color: Colors.white),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              /// Progress Ring
              GestureDetector(
                onTap: _handleProgressTap,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 1.1).animate(
                      CurvedAnimation(
                        parent: _ringController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: CustomPaint(
                        painter: _ProgressRingPainter(
                          fillPercentage: fillPercentage,
                          strokeWidth: 3,
                          primaryColor: Colors.blue.shade500,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            size: 24,
                            color: widget.habit.doneToday
                                ? Colors.blue.shade500
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              /// Habit Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.habit.frequency,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ScaleTransition(
                          scale: Tween<double>(begin: 1, end: 1.2).animate(
                            CurvedAnimation(
                              parent: _streakPulseController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: Text(
                            '🔥 ${widget.habit.streak}-day streak',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.red.shade500,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(7, (index) {
                              final isCompleted =
                                  widget.habit.weeklyStatus[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.green.shade500
                                        : Colors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              );
                            }),
                          ),
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

/// Progress Ring Custom Painter
class _ProgressRingPainter extends CustomPainter {
  final double fillPercentage;
  final double strokeWidth;
  final Color primaryColor;

  _ProgressRingPainter({
    required this.fillPercentage,
    required this.strokeWidth,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = -90.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    /// Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    /// Progress ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _degreesToRadians(startAngle),
      _degreesToRadians(360 * fillPercentage),
      false,
      Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }
}

/// Create Habit Modal
class _CreateHabitModal extends ConsumerStatefulWidget {
  const _CreateHabitModal();

  @override
  ConsumerState<_CreateHabitModal> createState() => _CreateHabitModalState();
}

class _CreateHabitModalState extends ConsumerState<_CreateHabitModal> {
  late TextEditingController _nameController;
  late String _selectedFrequency;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedFrequency = 'Daily';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createHabit() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    ref
        .read(habitControllerProvider.notifier)
        .createHabit(_nameController.text, _selectedFrequency);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Habit "${_nameController.text}" created')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Habit',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Habit name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue.shade500),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedFrequency,
              decoration: InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: ['Daily', '3× Weekly', '5× Weekly', 'Weekly']
                  .map(
                    (freq) => DropdownMenuItem(value: freq, child: Text(freq)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedFrequency = value ?? 'Daily');
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Create Habit',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Habit Detail Modal
class _HabitDetailModal extends ConsumerStatefulWidget {
  final Habit habit;

  const _HabitDetailModal({required this.habit});

  @override
  ConsumerState<_HabitDetailModal> createState() => _HabitDetailModalState();
}

class _HabitDetailModalState extends ConsumerState<_HabitDetailModal> {
  late TextEditingController _nameController;
  late String _selectedFrequency;
  late bool _reminderEnabled;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.name);
    _selectedFrequency = widget.habit.frequency;
    _reminderEnabled = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    final updatedHabit = widget.habit.copyWith(
      name: _nameController.text,
      frequency: _selectedFrequency,
    );
    ref.read(habitControllerProvider.notifier).updateHabit(updatedHabit);
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Habit updated')));
  }

  void _deleteHabit() {
    ref.read(habitControllerProvider.notifier).deleteHabit(widget.habit.id);
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Habit deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Habit name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue.shade500),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedFrequency,
              decoration: InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: ['Daily', '3× Weekly', '5× Weekly', 'Weekly']
                  .map(
                    (freq) => DropdownMenuItem(value: freq, child: Text(freq)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedFrequency = value ?? 'Daily');
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Streak',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.habit.streak} days',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.red.shade400,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _reminderEnabled,
              onChanged: (value) {
                setState(() => _reminderEnabled = value ?? false);
              },
              title: const Text('Enable reminder'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _deleteHabit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.red.shade500),
                ),
                child: const Text(
                  'Delete Habit',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
