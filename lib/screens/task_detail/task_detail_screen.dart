import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final DateTime? dueDate;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    this.dueDate,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    DateTime? dueDate,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Subtask {
  final String id;
  final String title;
  final bool completed;

  Subtask({required this.id, required this.title, required this.completed});

  Subtask copyWith({String? id, String? title, bool? completed}) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

class ActivityLog {
  final String id;
  final String message;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.message,
    required this.timestamp,
  });
}

final Map<String, Color> categoryColors = {
  'Personal': const Color(0xFFC7CEEA),
  'Work': const Color(0xFFFFE66D),
  'Study': const Color(0xFF95E1D3),
  'Fitness': const Color(0xFFA8E6CF),
};

final Map<String, Color> priorityColors = {
  'low': const Color(0xFF4CAF50),
  'medium': const Color(0xFFFFC107),
  'high': const Color(0xFFE53935),
};

Task _mockTask(String taskId) {
  final desc =
      'Create mockups and prototypes for the new marketing site. '
      'Include mobile-responsive layouts and accessibility considerations.';
  return Task(
    id: taskId,
    title: 'Design new landing page',
    description: desc,
    category: 'Work',
    priority: 'high',
    dueDate: DateTime.now().add(const Duration(days: 3)),
    completed: false,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  );
}

List<Subtask> _mockSubtasks() {
  return [
    Subtask(id: '1', title: 'Create wireframes', completed: true),
    Subtask(id: '2', title: 'Design mockups', completed: false),
    Subtask(id: '3', title: 'Get client feedback', completed: false),
  ];
}

List<String> _mockAttachments() {
  return ['design_spec.pdf', 'wireframes.fig', 'brand_guidelines.pdf'];
}

List<ActivityLog> _mockHistory() {
  return [
    ActivityLog(
      id: '1',
      message: 'Task created',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ActivityLog(
      id: '2',
      message: 'Description updated',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ActivityLog(
      id: '3',
      message: 'Priority changed to High',
      timestamp: DateTime.now().subtract(const Duration(hours: 24)),
    ),
    ActivityLog(
      id: '4',
      message: 'Subtask added: Design mockups',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];
}

final taskDetailProvider = StateProvider.family<Task, String>((ref, taskId) {
  return _mockTask(taskId);
});

final subtasksProvider = StateProvider.family<List<Subtask>, String>((
  ref,
  taskId,
) {
  return _mockSubtasks();
});

final attachmentsProvider = StateProvider.family<List<String>, String>((
  ref,
  taskId,
) {
  return _mockAttachments();
});

final taskHistoryProvider = StateProvider.family<List<ActivityLog>, String>((
  ref,
  taskId,
) {
  return _mockHistory();
});

final hasChangesProvider = StateProvider<bool>((ref) {
  return false;
});

final taskDetailControllerProvider =
    StateNotifierProvider<TaskDetailController, void>((ref) {
      return TaskDetailController(ref);
    });

class TaskDetailController extends StateNotifier<void> {
  final Ref ref;

  TaskDetailController(this.ref) : super(null);

  void updateTitle(String taskId, String newTitle) {
    final task = ref.read(taskDetailProvider(taskId));
    ref.read(taskDetailProvider(taskId).notifier).state = task.copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
    );
    ref.read(hasChangesProvider.notifier).state = true;
  }

  void updateDescription(String taskId, String? newDescription) {
    final task = ref.read(taskDetailProvider(taskId));
    ref.read(taskDetailProvider(taskId).notifier).state = task.copyWith(
      description: newDescription,
      updatedAt: DateTime.now(),
    );
    ref.read(hasChangesProvider.notifier).state = true;
  }

  void toggleCompleted(String taskId) {
    final task = ref.read(taskDetailProvider(taskId));
    ref.read(taskDetailProvider(taskId).notifier).state = task.copyWith(
      completed: !task.completed,
      updatedAt: DateTime.now(),
    );
    ref.read(hasChangesProvider.notifier).state = true;
  }

  void addSubtask(String taskId, String subtaskTitle) {
    final subtasks = ref.read(subtasksProvider(taskId));
    final newSubtask = Subtask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: subtaskTitle,
      completed: false,
    );
    ref.read(subtasksProvider(taskId).notifier).state = [
      ...subtasks,
      newSubtask,
    ];
  }

  void toggleSubtask(String taskId, String subtaskId) {
    final subtasks = ref.read(subtasksProvider(taskId));
    final index = subtasks.indexWhere((s) => s.id == subtaskId);
    if (index != -1) {
      final updated = [...subtasks];
      updated[index] = updated[index].copyWith(
        completed: !updated[index].completed,
      );
      ref.read(subtasksProvider(taskId).notifier).state = updated;
    }
  }

  void removeSubtask(String taskId, String subtaskId) {
    final subtasks = ref.read(subtasksProvider(taskId));
    ref.read(subtasksProvider(taskId).notifier).state = subtasks
        .where((s) => s.id != subtaskId)
        .toList();
  }

  void addAttachment(String taskId, String filename) {
    final attachments = ref.read(attachmentsProvider(taskId));
    ref.read(attachmentsProvider(taskId).notifier).state = [
      ...attachments,
      filename,
    ];
  }

  void removeAttachment(String taskId, String filename) {
    final attachments = ref.read(attachmentsProvider(taskId));
    ref.read(attachmentsProvider(taskId).notifier).state = attachments
        .where((a) => a != filename)
        .toList();
  }

  void saveChanges(String taskId) {
    debugPrint('Task saved');
    ref.read(hasChangesProvider.notifier).state = false;
  }
}

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subtaskController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _subtaskController = TextEditingController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showContextMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuTile('Duplicate Task', Icons.content_copy),
            _buildMenuTile('Move to Another Day', Icons.calendar_today),
            _buildMenuTile('Add to Favorites', Icons.favorite_outline),
            _buildMenuTile('Delete Task', Icons.delete, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    String label,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? const Color(0xFFE53935) : Colors.grey.shade600,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? const Color(0xFFE53935) : Colors.black87,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        debugPrint(label);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = ref.watch(taskDetailProvider(widget.taskId));
    final subtasks = ref.watch(subtasksProvider(widget.taskId));
    final attachments = ref.watch(attachmentsProvider(widget.taskId));
    final history = ref.watch(taskHistoryProvider(widget.taskId));
    final hasChanges = ref.watch(hasChangesProvider);
    final controller = ref.watch(taskDetailControllerProvider.notifier);

    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // HEADER
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back, size: 24),
                          ),
                          Text(
                            'Task Details',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          GestureDetector(
                            onTap: _showContextMenu,
                            child: const Icon(Icons.more_vert, size: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // TITLE + CHECKBOX
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                controller.toggleCompleted(widget.taskId),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12, top: 4),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: task.completed
                                      ? const Color(0xFF4CAF50)
                                      : Colors.white,
                                  border: Border.all(
                                    color: task.completed
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: task.completed
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              onChanged: (value) =>
                                  controller.updateTitle(widget.taskId, value),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: task.completed
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Task title',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // META CARD
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (categoryColors[task.category] ??
                                                const Color(0xFFE0E0E0))
                                            .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.category,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color:
                                              categoryColors[task.category] ??
                                              const Color(0xFF616161),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color:
                                        priorityColors[task.priority] ??
                                        const Color(0xFF9E9E9E),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _capitalize(task.priority),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildMetaField(
                              'Due Date',
                              task.dueDate != null
                                  ? '${task.dueDate!.month}/${task.dueDate!.day}/${task.dueDate!.year}'
                                  : 'Not set',
                            ),
                            const SizedBox(height: 12),
                            _buildMetaField(
                              'Created',
                              _formatDate(task.createdAt),
                            ),
                            const SizedBox(height: 12),
                            _buildMetaField(
                              'Updated',
                              _formatDate(task.updatedAt),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // DESCRIPTION
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descriptionController,
                            onChanged: (value) => controller.updateDescription(
                              widget.taskId,
                              value,
                            ),
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Add a description…',
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
                                borderSide: const BorderSide(
                                  color: Color(0xFF2196F3),
                                  width: 1.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.withValues(alpha: 0.02),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // SUBTASKS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtasks',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _showAddSubtaskModal(context, controller),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.add,
                                        size: 16,
                                        color: Color(0xFF2196F3),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Add',
                                        style: TextStyle(
                                          color: Color(0xFF2196F3),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (subtasks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'No subtasks',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade500),
                              ),
                            )
                          else
                            ...subtasks.asMap().entries.map((entry) {
                              final index = entry.key;
                              final subtask = entry.value;
                              return Dismissible(
                                key: Key(subtask.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => controller.removeSubtask(
                                  widget.taskId,
                                  subtask.id,
                                ),
                                background: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index < subtasks.length - 1 ? 8 : 0,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(
                                        alpha: 0.05,
                                      ),
                                      border: Border.all(
                                        color: Colors.grey.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => controller.toggleSubtask(
                                            widget.taskId,
                                            subtask.id,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: subtask.completed
                                                  ? const Color(0xFF4CAF50)
                                                  : Colors.white,
                                              border: Border.all(
                                                color: subtask.completed
                                                    ? const Color(0xFF4CAF50)
                                                    : Colors.grey.withValues(
                                                        alpha: 0.3,
                                                      ),
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: subtask.completed
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 12,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            subtask.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  decoration: subtask.completed
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                  color: subtask.completed
                                                      ? Colors.grey.shade500
                                                      : Colors.black87,
                                                ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.drag_handle,
                                          size: 16,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  // ATTACHMENTS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Attachments',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              GestureDetector(
                                onTap: () {
                                  final filename =
                                      'attachment_${DateTime.now().millisecondsSinceEpoch}.pdf';
                                  controller.addAttachment(
                                    widget.taskId,
                                    filename,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.add,
                                        size: 16,
                                        color: Color(0xFF2196F3),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Add',
                                        style: TextStyle(
                                          color: Color(0xFF2196F3),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (attachments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'No attachments',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade500),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: attachments
                                  .map(
                                    (file) => GestureDetector(
                                      onLongPress: () =>
                                          controller.removeAttachment(
                                            widget.taskId,
                                            file,
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withValues(
                                            alpha: 0.05,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.description,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              file.split('_').first,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // ACTIVITY LOG
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activity Log',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: history
                                .map(
                                  (log) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2196F3),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            if (log != history.last)
                                              Container(
                                                width: 2,
                                                height: 30,
                                                color: Colors.grey.withValues(
                                                  alpha: 0.2,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                log.message,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatDate(log.timestamp),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // DANGER ZONE
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(
                              0xFFE53935,
                            ).withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Danger Zone',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFE53935),
                                  ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => _showDeleteConfirmation(
                                  context,
                                  controller,
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFE53935),
                                  ),
                                  foregroundColor: const Color(0xFFE53935),
                                ),
                                child: const Text('Delete Task'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // FOOTER SPACING
                  SliverToBoxAdapter(child: SizedBox(height: 180)),
                ],
              ),
              // SAVE FAB
              if (hasChanges)
                Positioned(
                  bottom: 24,
                  right: 20,
                  child: AnimatedSlide(
                    offset: hasChanges ? Offset.zero : const Offset(0, 2),
                    duration: const Duration(milliseconds: 300),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        controller.saveChanges(widget.taskId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Changes saved'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      label: const Text('Save'),
                      icon: const Icon(Icons.check),
                      elevation: 0,
                      backgroundColor: const Color(0xFF2196F3),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaField(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  String _capitalize(String text) {
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  void _showAddSubtaskModal(
    BuildContext context,
    TaskDetailController controller,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
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
              'Add Subtask',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subtaskController,
              decoration: InputDecoration(
                hintText: 'Subtask name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_subtaskController.text.isNotEmpty) {
                    controller.addSubtask(
                      widget.taskId,
                      _subtaskController.text,
                    );
                    _subtaskController.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TaskDetailController controller,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete Task',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure? This action cannot be undone.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
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
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
