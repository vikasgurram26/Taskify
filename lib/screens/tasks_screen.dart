import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Models
class Task {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final DateTime? dueDate;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    this.dueDate,
    this.completed = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    DateTime? dueDate,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
    );
  }
}

class TasksFilter {
  final String searchQuery;
  final List<String> selectedCategories;
  final List<String> selectedPriorities;
  final List<String> selectedStatuses;

  TasksFilter({
    this.searchQuery = '',
    this.selectedCategories = const [],
    this.selectedPriorities = const [],
    this.selectedStatuses = const [],
  });

  TasksFilter copyWith({
    String? searchQuery,
    List<String>? selectedCategories,
    List<String>? selectedPriorities,
    List<String>? selectedStatuses,
  }) {
    return TasksFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedPriorities: selectedPriorities ?? this.selectedPriorities,
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
    );
  }
}

/// Mock Data
final List<Task> mockTasks = [
  Task(
    id: '1',
    title: 'Design new landing page',
    description: 'Create mockups and prototypes for the new marketing site',
    category: 'Design',
    priority: 'high',
    dueDate: DateTime.now().add(const Duration(days: 2)),
    completed: false,
  ),
  Task(
    id: '2',
    title: 'Review pull requests',
    description: 'Check pending PRs from the team',
    category: 'Development',
    priority: 'medium',
    dueDate: DateTime.now().add(const Duration(days: 1)),
    completed: false,
  ),
  Task(
    id: '3',
    title: 'Update documentation',
    category: 'Documentation',
    priority: 'low',
    dueDate: DateTime.now().add(const Duration(days: 5)),
    completed: false,
  ),
  Task(
    id: '4',
    title: 'Fix login bug',
    description: 'Users reporting timeout on login page',
    category: 'Development',
    priority: 'high',
    dueDate: DateTime.now(),
    completed: false,
  ),
  Task(
    id: '5',
    title: 'Client meeting notes',
    category: 'Communication',
    priority: 'medium',
    dueDate: DateTime.now().subtract(const Duration(days: 1)),
    completed: true,
  ),
  Task(
    id: '6',
    title: 'Setup CI/CD pipeline',
    description: 'Configure GitHub Actions for automated testing',
    category: 'DevOps',
    priority: 'high',
    dueDate: DateTime.now().add(const Duration(days: 3)),
    completed: false,
  ),
];

final Map<String, Color> categoryColors = {
  'Design': Color(0xFFFF6B6B),
  'Development': Color(0xFF4ECDC4),
  'Documentation': Color(0xFF95E1D3),
  'Communication': Color(0xFFFFE66D),
  'DevOps': Color(0xFFA8E6CF),
  'General': Color(0xFFC7CEEA),
};

/// Providers
final tasksProvider = StateProvider<List<Task>>((ref) {
  return mockTasks;
});

final tasksFilterProvider = StateProvider<TasksFilter>((ref) {
  return TasksFilter();
});

final filteredTasksProvider = StateProvider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(tasksFilterProvider);

  return tasks.where((task) {
    if (filter.searchQuery.isNotEmpty) {
      if (!task.title.toLowerCase().contains(
        filter.searchQuery.toLowerCase(),
      )) {
        return false;
      }
    }

    if (filter.selectedCategories.isNotEmpty) {
      if (!filter.selectedCategories.contains(task.category)) {
        return false;
      }
    }

    if (filter.selectedPriorities.isNotEmpty) {
      if (!filter.selectedPriorities.contains(task.priority)) {
        return false;
      }
    }

    if (filter.selectedStatuses.isNotEmpty) {
      final taskStatus = task.completed ? 'done' : 'todo';
      if (!filter.selectedStatuses.contains(taskStatus)) {
        return false;
      }
    }

    return true;
  }).toList();
});

final showTasksFabProvider = StateProvider<bool>((ref) {
  return true;
});

final taskActionsProvider = StateNotifierProvider<TaskActionsController, void>((
  ref,
) {
  return TaskActionsController(ref);
});

final quickAddProvider = StateProvider<String>((ref) {
  return '';
});

class TaskActionsController extends StateNotifier<void> {
  final Ref ref;

  TaskActionsController(this.ref) : super(null);

  void toggleComplete(String taskId) {
    final tasks = ref.read(tasksProvider);
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = tasks[index];
      final updatedTasks = [...tasks];
      updatedTasks[index] = task.copyWith(completed: !task.completed);
      ref.read(tasksProvider.notifier).state = updatedTasks;
      debugPrint('Task toggled: ${task.title}');
    }
  }

  void deleteTask(String taskId) {
    final tasks = ref.read(tasksProvider);
    final updatedTasks = tasks.where((t) => t.id != taskId).toList();
    ref.read(tasksProvider.notifier).state = updatedTasks;
    debugPrint('Task deleted: $taskId');
  }

  void createTask(
    String title, {
    String? description,
    String category = 'General',
    String priority = 'medium',
  }) {
    if (title.isEmpty) return;
    final tasks = ref.read(tasksProvider);
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      priority: priority,
      dueDate: null,
    );
    ref.read(tasksProvider.notifier).state = [...tasks, newTask];
    debugPrint('Task created: $title');
  }

  void updateTask(Task updatedTask) {
    final tasks = ref.read(tasksProvider);
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      final updatedTasks = [...tasks];
      updatedTasks[index] = updatedTask;
      ref.read(tasksProvider.notifier).state = updatedTasks;
      debugPrint('Task updated: ${updatedTask.title}');
    }
  }
}

/// Main Screen
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _searchController = TextEditingController();
    _fadeController.forward();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final showFab = _scrollController.offset < 100;
    ref.read(showTasksFabProvider.notifier).state = showFab;
  }

  void _openSortModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _SortModal(),
    );
  }

  void _openCreateTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _CreateTaskModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final showFab = ref.watch(showTasksFabProvider);
    final filter = ref.watch(tasksFilterProvider);

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
                    'Tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _openSortModal,
                        icon: const Icon(Icons.sort, size: 20),
                        splashRadius: 24,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _openCreateTaskModal,
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

          /// Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(tasksFilterProvider.notifier).state = filter
                      .copyWith(searchQuery: value);
                },
                decoration: InputDecoration(
                  hintText: 'Search tasks…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            ref.read(tasksFilterProvider.notifier).state =
                                filter.copyWith(searchQuery: '');
                          },
                          child: const Icon(Icons.close, size: 20),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade500,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.02),
                ),
              ),
            ),
          ),

          /// Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ...[
                      (
                        'High',
                        'high',
                        filter.selectedPriorities.contains('high'),
                      ),
                      (
                        'Medium',
                        'medium',
                        filter.selectedPriorities.contains('medium'),
                      ),
                      ('Low', 'low', filter.selectedPriorities.contains('low')),
                    ].map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: item.$1,
                          isSelected: item.$3,
                          onTap: () {
                            final selected = List<String>.from(
                              filter.selectedPriorities,
                            );
                            if (selected.contains(item.$2)) {
                              selected.remove(item.$2);
                            } else {
                              selected.add(item.$2);
                            }
                            ref.read(tasksFilterProvider.notifier).state =
                                filter.copyWith(selectedPriorities: selected);
                          },
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    ...[
                      (
                        'To-do',
                        'todo',
                        filter.selectedStatuses.contains('todo'),
                      ),
                      (
                        'Done',
                        'done',
                        filter.selectedStatuses.contains('done'),
                      ),
                    ].map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: item.$1,
                          isSelected: item.$3,
                          onTap: () {
                            final selected = List<String>.from(
                              filter.selectedStatuses,
                            );
                            if (selected.contains(item.$2)) {
                              selected.remove(item.$2);
                            } else {
                              selected.add(item.$2);
                            }
                            ref.read(tasksFilterProvider.notifier).state =
                                filter.copyWith(selectedStatuses: selected);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          /// Tasks List
          if (filteredTasks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 64,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nothing here!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting filters or adding a task.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _openCreateTaskModal,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade500,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: filteredTasks.map((task) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TaskCard(
                        task: task,
                        onToggle: () => ref
                            .read(taskActionsProvider.notifier)
                            .toggleComplete(task.id),
                        onDelete: () => ref
                            .read(taskActionsProvider.notifier)
                            .deleteTask(task.id),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          /// Bottom spacing
          SliverToBoxAdapter(child: SizedBox(height: 140)),
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
            onPressed: _openCreateTaskModal,
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

/// Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade500 : Colors.white,
            border: Border.all(
              color: isSelected
                  ? Colors.blue.shade500
                  : Colors.grey.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Task Card Widget
class _TaskCard extends ConsumerStatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  ConsumerState<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<_TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (_isExpanded) {
      _expandController.reverse();
    } else {
      _expandController.forward();
    }
    setState(() => _isExpanded = !_isExpanded);
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.yellow.shade600;
      case 'low':
        return Colors.green.shade500;
      default:
        return Colors.grey.shade400;
    }
  }

  String _formatDueDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (dateOnly.isBefore(today)) return 'Overdue';

    return '${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.task.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          widget.onDelete();
        } else if (direction == DismissDirection.startToEnd) {
          widget.onToggle();
        }
      },
      background: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade500,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onLongPress: () =>
            debugPrint('Long press to reorder: ${widget.task.title}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Checkbox
                  GestureDetector(
                    onTap: widget.onToggle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, top: 2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: widget.task.completed
                              ? Colors.green.shade500
                              : Colors.white,
                          border: Border.all(
                            color: widget.task.completed
                                ? Colors.green.shade500
                                : Colors.grey.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: widget.task.completed
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),

                  /// Title & Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: widget.task.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: widget.task.completed
                                    ? Colors.grey.shade500
                                    : Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (categoryColors[widget.task.category] ??
                                            Colors.grey)
                                        .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.task.category,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color:
                                          categoryColors[widget
                                              .task
                                              .category] ??
                                          Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _getPriorityColor(widget.task.priority),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            if (widget.task.dueDate != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                _formatDueDate(widget.task.dueDate),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// Menu
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () => debugPrint('Edit: ${widget.task.title}'),
                      ),
                      PopupMenuItem(
                        child: const Text('Duplicate'),
                        onTap: () =>
                            debugPrint('Duplicate: ${widget.task.title}'),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () => widget.onDelete(),
                      ),
                    ],
                    offset: const Offset(0, 40),
                  ),
                ],
              ),

              /// Description
              if (widget.task.description != null &&
                  widget.task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 32, top: 12),
                  child: SizeTransition(
                    sizeFactor: _expandController,
                    child: GestureDetector(
                      onTap: _toggleExpand,
                      child: Text(
                        widget.task.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        maxLines: _isExpanded ? null : 2,
                        overflow: _isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sort Modal
class _SortModal extends ConsumerWidget {
  const _SortModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort By',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ...[
            ('Priority (High → Low)', Icons.priority_high),
            ('Due Date (Soon → Later)', Icons.calendar_today),
            ('Category (A → Z)', Icons.category),
            ('Creation Date (Newest → Oldest)', Icons.access_time),
          ].map((item) {
            return GestureDetector(
              onTap: () {
                debugPrint('Sort by: ${item.$1}');
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(item.$2, size: 18, color: Colors.blue.shade500),
                      const SizedBox(width: 12),
                      Text(
                        item.$1,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Create Task Modal
class _CreateTaskModal extends ConsumerStatefulWidget {
  const _CreateTaskModal();

  @override
  ConsumerState<_CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends ConsumerState<_CreateTaskModal> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late String _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedCategory = 'General';
    _selectedPriority = 'medium';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    ref
        .read(taskActionsProvider.notifier)
        .createTask(
          _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          category: _selectedCategory,
          priority: _selectedPriority,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "${_titleController.text}" created')),
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
              'Create Task',
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
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Description (optional)',
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
                    items: [
                      ...categoryColors.keys.map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategory = value ?? 'General');
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
                    items: [
                      ...['low', 'medium', 'high'].map(
                        (pri) => DropdownMenuItem(
                          value: pri,
                          child: Text(pri.capitalize()),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedPriority = value ?? 'medium');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Create Task',
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

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
