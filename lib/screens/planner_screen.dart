import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Models
class PlannerTask {
  final String id;
  final String title;
  final String category;
  final String priority;
  final TimeOfDay start;
  final TimeOfDay end;
  final bool isAllDay;
  final String categoryColor;

  PlannerTask({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.start,
    required this.end,
    this.isAllDay = false,
    required this.categoryColor,
  });

  PlannerTask copyWith({
    String? id,
    String? title,
    String? category,
    String? priority,
    TimeOfDay? start,
    TimeOfDay? end,
    bool? isAllDay,
    String? categoryColor,
  }) {
    return PlannerTask(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      start: start ?? this.start,
      end: end ?? this.end,
      isAllDay: isAllDay ?? this.isAllDay,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }
}

class DragState {
  final String? taskId;
  final Offset? currentOffset;
  final TimeOfDay? suggestedTime;

  DragState({this.taskId, this.currentOffset, this.suggestedTime});
}

/// Providers
final selectedDayProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final tasksForDayProvider = StateProvider.family<List<PlannerTask>, DateTime>((
  ref,
  date,
) {
  return mockTasksByDay[_dateKey(date)] ?? [];
});

final allDayTasksProvider = StateProvider.family<List<PlannerTask>, DateTime>((
  ref,
  date,
) {
  final allTasks = ref.watch(tasksForDayProvider(date));
  return allTasks.where((task) => task.isAllDay).toList();
});

final timelineTasksProvider = StateProvider.family<List<PlannerTask>, DateTime>(
  (ref, date) {
    final allTasks = ref.watch(tasksForDayProvider(date));
    return allTasks.where((task) => !task.isAllDay).toList()..sort((a, b) {
      final aMinutes = a.start.hour * 60 + a.start.minute;
      final bMinutes = b.start.hour * 60 + b.start.minute;
      return aMinutes.compareTo(bMinutes);
    });
  },
);

final dragControllerProvider = StateProvider<DragState>((ref) {
  return DragState();
});

final showQuickAddProvider = StateProvider<bool>((ref) {
  return true;
});

/// Mock data
final Map<String, List<PlannerTask>> mockTasksByDay = {
  _dateKey(DateTime.now()): [
    PlannerTask(
      id: '1',
      title: 'Team Standup',
      category: 'Meeting',
      priority: 'High',
      start: const TimeOfDay(hour: 9, minute: 0),
      end: const TimeOfDay(hour: 9, minute: 30),
      categoryColor: '#FF6B6B',
    ),
    PlannerTask(
      id: '2',
      title: 'Design Review',
      category: 'Meeting',
      priority: 'High',
      start: const TimeOfDay(hour: 10, minute: 0),
      end: const TimeOfDay(hour: 11, minute: 0),
      categoryColor: '#FF6B6B',
    ),
    PlannerTask(
      id: '3',
      title: 'Lunch Break',
      category: 'Personal',
      priority: 'Medium',
      start: const TimeOfDay(hour: 12, minute: 0),
      end: const TimeOfDay(hour: 13, minute: 0),
      categoryColor: '#4ECDC4',
    ),
    PlannerTask(
      id: '4',
      title: 'Code Review',
      category: 'Work',
      priority: 'High',
      start: const TimeOfDay(hour: 14, minute: 0),
      end: const TimeOfDay(hour: 15, minute: 30),
      categoryColor: '#95E1D3',
    ),
    PlannerTask(
      id: '5',
      title: 'Frontend Updates',
      category: 'Work',
      priority: 'Medium',
      start: const TimeOfDay(hour: 16, minute: 0),
      end: const TimeOfDay(hour: 17, minute: 30),
      categoryColor: '#95E1D3',
    ),
    PlannerTask(
      id: '6',
      title: 'Project Planning',
      category: 'Meeting',
      priority: 'High',
      isAllDay: true,
      start: const TimeOfDay(hour: 0, minute: 0),
      end: const TimeOfDay(hour: 23, minute: 59),
      categoryColor: '#FF6B6B',
    ),
  ],
};

String _dateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Main Screen
class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen>
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
    ref.read(showQuickAddProvider.notifier).state = showFab;
  }

  void _openQuickAddModal() {
    final selectedDay = ref.read(selectedDayProvider);
    showModalBottomSheet(
      context: context,
      builder: (context) => _QuickAddTaskModal(selectedDay: selectedDay),
    );
  }

  void _openDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.read(selectedDayProvider),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      ref.read(selectedDayProvider.notifier).state = picked;
      _fadeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);
    final showFab = ref.watch(showQuickAddProvider);

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
                    'Planner',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _openDatePicker,
                        icon: const Icon(Icons.calendar_today, size: 20),
                        splashRadius: 24,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          ref.read(selectedDayProvider.notifier).state =
                              DateTime.now();
                          _fadeController.forward(from: 0);
                        },
                        child: const Text('Today'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// Week Strip
          SliverToBoxAdapter(
            child: _WeekStrip(
              selectedDay: selectedDay,
              fadeController: _fadeController,
            ),
          ),

          /// Date Summary Header
          SliverToBoxAdapter(
            child: _DateSummaryHeader(
              selectedDay: selectedDay,
              fadeController: _fadeController,
            ),
          ),

          /// All-Day Tasks Section
          SliverToBoxAdapter(
            child: _AllDayTasksSection(selectedDay: selectedDay),
          ),

          /// Timeline
          SliverToBoxAdapter(child: _TimelineSection(selectedDay: selectedDay)),

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
            onPressed: _openQuickAddModal,
            label: const Text('Add Task'),
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

/// Week Strip Widget
class _WeekStrip extends ConsumerStatefulWidget {
  final DateTime selectedDay;
  final AnimationController fadeController;

  const _WeekStrip({required this.selectedDay, required this.fadeController});

  @override
  ConsumerState<_WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends ConsumerState<_WeekStrip> {
  late ScrollController _weekScrollController;

  @override
  void initState() {
    super.initState();
    _weekScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelectedDay());
  }

  @override
  void didUpdateWidget(covariant _WeekStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDay != widget.selectedDay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelectedDay());
    }
  }

  void _centerSelectedDay() {
    try {
      final today = DateTime.now();
      final diff = widget.selectedDay.difference(today).inDays;
      final offset = diff * 80.0;
      _weekScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      // Error animating scroll, ignore
    }
  }

  @override
  void dispose() {
    _weekScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.add(Duration(days: i - 3)));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          controller: _weekScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: days.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemBuilder: (context, index) {
            final day = days[index];
            final isSelected = _isSameDay(day, widget.selectedDay);
            final isToday = _isSameDay(day, today);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedDayProvider.notifier).state = day;
                  widget.fadeController.forward(from: 0);
                },
                onLongPress: () {
                  _showQuickAddAtDay(day);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade500 : Colors.white,
                      border: Border.all(
                        color: isToday && !isSelected
                            ? Colors.blue.shade500
                            : Colors.grey.withValues(alpha: 0.2),
                        width: isToday && !isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ][day.weekday - 1],
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showQuickAddAtDay(DateTime day) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _QuickAddTaskModal(selectedDay: day),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Date Summary Header
class _DateSummaryHeader extends ConsumerWidget {
  final DateTime selectedDay;
  final AnimationController fadeController;

  const _DateSummaryHeader({
    required this.selectedDay,
    required this.fadeController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksForDay = ref.watch(tasksForDayProvider(selectedDay));
    final taskCount = tasksForDay.length;

    final monthNames = [
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
    ];

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: fadeController, curve: Curves.easeInOut),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][selectedDay.weekday - 1]}, ${selectedDay.day} ${monthNames[selectedDay.month - 1]} ${selectedDay.year}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have $taskCount ${taskCount == 1 ? 'task' : 'tasks'} today',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

/// All-Day Tasks Section
class _AllDayTasksSection extends ConsumerWidget {
  final DateTime selectedDay;

  const _AllDayTasksSection({required this.selectedDay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDayTasks = ref.watch(allDayTasksProvider(selectedDay));

    if (allDayTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All-day',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: allDayTasks.map((task) {
              return GestureDetector(
                onTap: () {
                  debugPrint('Open task detail: ${task.title}');
                },
                onLongPress: () {
                  debugPrint('Reorder chip: ${task.title}');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.15),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _hexToColor(task.categoryColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Timeline Section
class _TimelineSection extends ConsumerStatefulWidget {
  final DateTime selectedDay;

  const _TimelineSection({required this.selectedDay});

  @override
  ConsumerState<_TimelineSection> createState() => _TimelineSectionState();
}

class _TimelineSectionState extends ConsumerState<_TimelineSection> {
  late Map<String, Offset> taskOffsets;

  @override
  void initState() {
    super.initState();
    taskOffsets = {};
  }

  @override
  Widget build(BuildContext context) {
    final timelineTasks = ref.watch(timelineTasksProvider(widget.selectedDay));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(17, (hourIndex) {
          final hour = 7 + hourIndex;
          final hourLabel = hour > 12 ? '${hour - 12}:00 PM' : '$hour:00 AM';
          final tasksAtHour = timelineTasks
              .where((task) => task.start.hour == hour)
              .toList();

          return Column(
            children: [
              SizedBox(
                height: 60,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        hourLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            child: Divider(
                              color: Colors.grey.withValues(alpha: 0.1),
                              thickness: 1,
                              height: 1,
                            ),
                          ),
                          if (tasksAtHour.isNotEmpty)
                            Column(
                              children: tasksAtHour.map((task) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: _TaskBlock(
                                    task: task,
                                    onTap: () {
                                      debugPrint(
                                        'Open task detail: ${task.title}',
                                      );
                                    },
                                    onDoubleTap: () {
                                      debugPrint('Quick edit: ${task.title}');
                                    },
                                  ),
                                );
                              }).toList(),
                            )
                          else
                            GestureDetector(
                              onTap: () {
                                debugPrint('Add task at $hourLabel');
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => _QuickAddTaskModal(
                                    selectedDay: widget.selectedDay,
                                    suggestedHour: hour,
                                  ),
                                );
                              },
                              child: Container(color: Colors.transparent),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Task Block Widget
class _TaskBlock extends ConsumerWidget {
  final PlannerTask task;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const _TaskBlock({
    required this.task,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationMinutes =
        (task.end.hour - task.start.hour) * 60 +
        (task.end.minute - task.start.minute);
    final blockHeight = (durationMinutes / 60) * 60;

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: () {
        debugPrint('Long press to drag: ${task.title}');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: blockHeight > 30 ? blockHeight : 30,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.05),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _hexToColor(task.categoryColor),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${task.start.format(context)} – ${task.end.format(context)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: task.priority == 'High'
                      ? Colors.red.shade400
                      : Colors.yellow.shade600,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick Add Task Modal
class _QuickAddTaskModal extends ConsumerStatefulWidget {
  final DateTime selectedDay;
  final int? suggestedHour;

  const _QuickAddTaskModal({required this.selectedDay, this.suggestedHour});

  @override
  ConsumerState<_QuickAddTaskModal> createState() => _QuickAddTaskModalState();
}

class _QuickAddTaskModalState extends ConsumerState<_QuickAddTaskModal> {
  late TextEditingController _titleController;
  late String _selectedCategory;
  late String _selectedPriority;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isAllDay;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _selectedCategory = 'Work';
    _selectedPriority = 'Medium';
    _startTime = TimeOfDay(hour: widget.suggestedHour ?? 9, minute: 0);
    _endTime = TimeOfDay(hour: (widget.suggestedHour ?? 9) + 1, minute: 0);
    _isAllDay = false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    final newTask = PlannerTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      category: _selectedCategory,
      priority: _selectedPriority,
      start: _startTime,
      end: _endTime,
      isAllDay: _isAllDay,
      categoryColor: _getCategoryColor(_selectedCategory),
    );

    final key = _dateKey(widget.selectedDay);
    mockTasksByDay.putIfAbsent(key, () => []);
    mockTasksByDay[key]!.add(newTask);

    ref.invalidate(tasksForDayProvider(widget.selectedDay));
    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Task "${newTask.title}" added')));
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
              'Add Task',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Task title',
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
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: ['Work', 'Meeting', 'Personal', 'Break']
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value ?? 'Work');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedPriority,
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: ['Low', 'Medium', 'High']
                        .map(
                          (pri) =>
                              DropdownMenuItem(value: pri, child: Text(pri)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedPriority = value ?? 'Medium');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _isAllDay,
              onChanged: (value) {
                setState(() => _isAllDay = value ?? false);
              },
              title: const Text('All-day task'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (!_isAllDay) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (time != null) {
                          setState(() => _startTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Time',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _startTime.format(context),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (time != null) {
                          setState(() => _endTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Time',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _endTime.format(context),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Task',
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

/// Utility Functions
Color _hexToColor(String hex) {
  hex = hex.replaceFirst('#', '');
  return Color(int.parse(hex, radix: 16) + 0xFF000000);
}

String _getCategoryColor(String category) {
  const colors = {
    'Work': '#95E1D3',
    'Meeting': '#FF6B6B',
    'Personal': '#4ECDC4',
    'Break': '#FFE66D',
  };
  return colors[category] ?? '#95E1D3';
}
