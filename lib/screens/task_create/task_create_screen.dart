import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Models
class TaskCreateModel {
  final String title;
  final String? description;
  final String category;
  final String priority;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final List<String> attachments;
  final bool reminder;
  final TimeOfDay? reminderTime;
  final String? titleError;
  final bool isLoading;

  TaskCreateModel({
    this.title = '',
    this.description,
    this.category = 'Personal',
    this.priority = 'medium',
    this.dueDate,
    this.dueTime,
    this.attachments = const [],
    this.reminder = false,
    this.reminderTime,
    this.titleError,
    this.isLoading = false,
  });

  TaskCreateModel copyWith({
    String? title,
    String? description,
    String? category,
    String? priority,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    List<String>? attachments,
    bool? reminder,
    TimeOfDay? reminderTime,
    String? titleError,
    bool? isLoading,
  }) {
    return TaskCreateModel(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      attachments: attachments ?? this.attachments,
      reminder: reminder ?? this.reminder,
      reminderTime: reminderTime ?? this.reminderTime,
      titleError: titleError ?? this.titleError,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

const List<String> categoryOptions = [
  'Personal',
  'Work',
  'Study',
  'Fitness',
  'Custom',
];

final Map<String, Color> categoryColors = {
  'Personal': Color(0xFFC7CEEA),
  'Work': Color(0xFFFFE66D),
  'Study': Color(0xFF95E1D3),
  'Fitness': Color(0xFFA8E6CF),
  'Custom': Color(0xFFFF6B6B),
};

/// Providers
final taskCreateFormProvider = StateProvider<TaskCreateModel>((ref) {
  return TaskCreateModel();
});

final taskCreateControllerProvider =
    StateNotifierProvider<TaskCreateController, void>((ref) {
      return TaskCreateController(ref);
    });

class TaskCreateController extends StateNotifier<void> {
  final Ref ref;

  TaskCreateController(this.ref) : super(null);

  void updateTitle(String value) {
    final form = ref.read(taskCreateFormProvider);
    ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
      title: value,
      titleError: null,
    );
  }

  void updateDescription(String value) {
    final form = ref.read(taskCreateFormProvider);
    ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
      description: value.isEmpty ? null : value,
    );
  }

  void updateCategory(String value) {
    final form = ref.read(taskCreateFormProvider);
    ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
      category: value,
    );
  }

  void updatePriority(String value) {
    final form = ref.read(taskCreateFormProvider);
    ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
      priority: value,
    );
  }

  void updateDueDate(DateTime? value) {
    final form = ref.read(taskCreateFormProvider);
    ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
      dueDate: value,
    );
  }

  void updateDueTime(TimeOfDay? value) {
    final form = ref.read(taskCreateFormProvider);
    ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
      dueTime: value,
    );
  }

  void toggleReminder() {
    final form = ref.read(taskCreateFormProvider);
    ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
      reminder: !form.reminder,
    );
  }

  void updateReminderTime(TimeOfDay? value) {
    final form = ref.read(taskCreateFormProvider);
    ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
      reminderTime: value,
    );
  }

  void addAttachment(String filename) {
    final form = ref.read(taskCreateFormProvider);
    if (form.attachments.length < 3) {
      final newAttachments = [...form.attachments, filename];
      ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
        attachments: newAttachments,
      );
    }
  }

  void removeAttachment(int index) {
    final form = ref.read(taskCreateFormProvider);
    final newAttachments = [...form.attachments]..removeAt(index);
    ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
      attachments: newAttachments,
    );
  }

  Future<void> submitTask() async {
    final form = ref.read(taskCreateFormProvider);

    if (form.title.isEmpty) {
      ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
        titleError: 'Title is required',
      );
      return;
    }

    ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
      isLoading: true,
    );

    await Future.delayed(const Duration(seconds: 1));

    debugPrint(
      'Task Created:\n'
      '  Title: ${form.title}\n'
      '  Description: ${form.description ?? "N/A"}\n'
      '  Category: ${form.category}\n'
      '  Priority: ${form.priority}\n'
      '  Due Date: ${form.dueDate}\n'
      '  Due Time: ${form.dueTime}\n'
      '  Attachments: ${form.attachments}\n'
      '  Reminder: ${form.reminder ? "Yes (${form.reminderTime})" : "No"}',
    );

    ref.read(taskCreateFormProvider.notifier).state = form.copyWith(
      isLoading: false,
    );
  }
}

/// Main Screen
class TaskCreateScreen extends ConsumerStatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  ConsumerState<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends ConsumerState<TaskCreateScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
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
    _fadeController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    await ref.read(taskCreateControllerProvider.notifier).submitTask();
    if (mounted && !ref.read(taskCreateFormProvider).isLoading) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(taskCreateFormProvider);
    final controller = ref.watch(taskCreateControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: CustomScrollView(
            slivers: [
              /// Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create Task',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 28,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 24),
                      ),
                    ],
                  ),
                ),
              ),

              /// Form Container
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title Field
                        _buildLabel(context, 'Task Title'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          onChanged: controller.updateTitle,
                          decoration: InputDecoration(
                            hintText: 'Enter task title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: form.titleError != null
                                    ? Colors.red.shade400
                                    : Colors.grey.withValues(alpha: 0.15),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: form.titleError != null
                                    ? Colors.red.shade400
                                    : Colors.grey.withValues(alpha: 0.15),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: form.titleError != null
                                    ? Colors.red.shade400
                                    : Colors.blue.shade500,
                                width: 1.5,
                              ),
                            ),
                            errorText: form.titleError,
                            filled: true,
                            fillColor: Colors.grey.withValues(alpha: 0.02),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 16,
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        const SizedBox(height: 24),

                        /// Description Field
                        _buildLabel(context, 'Description'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          onChanged: controller.updateDescription,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Add details… (optional)',
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
                            filled: true,
                            fillColor: Colors.grey.withValues(alpha: 0.02),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 24),

                        /// Category Dropdown
                        _buildLabel(context, 'Category'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: form.category,
                          decoration: InputDecoration(
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
                            filled: true,
                            fillColor: Colors.grey.withValues(alpha: 0.02),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.bookmark_outline,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          items: [
                            ...categoryOptions.map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) controller.updateCategory(value);
                          },
                        ),

                        const SizedBox(height: 24),

                        /// Priority Selector
                        _buildLabel(context, 'Priority'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.updatePriority('low'),
                                child: AnimatedScale(
                                  scale: form.priority == 'low' ? 1.05 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: form.priority == 'low'
                                          ? Colors.green.shade500.withValues(
                                              alpha: 0.15,
                                            )
                                          : Colors.white,
                                      border: Border.all(
                                        color: form.priority == 'low'
                                            ? Colors.green.shade500
                                            : Colors.grey.withValues(
                                                alpha: 0.2,
                                              ),
                                        width: form.priority == 'low' ? 1.5 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade500,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Low',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: form.priority == 'low'
                                                    ? Colors.green.shade500
                                                    : Colors.grey.shade700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    controller.updatePriority('medium'),
                                child: AnimatedScale(
                                  scale: form.priority == 'medium' ? 1.05 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: form.priority == 'medium'
                                          ? Colors.yellow.shade600.withValues(
                                              alpha: 0.15,
                                            )
                                          : Colors.white,
                                      border: Border.all(
                                        color: form.priority == 'medium'
                                            ? Colors.yellow.shade600
                                            : Colors.grey.withValues(
                                                alpha: 0.2,
                                              ),
                                        width: form.priority == 'medium'
                                            ? 1.5
                                            : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.yellow.shade600,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Medium',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: form.priority == 'medium'
                                                    ? Colors.yellow.shade600
                                                    : Colors.grey.shade700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.updatePriority('high'),
                                child: AnimatedScale(
                                  scale: form.priority == 'high' ? 1.05 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: form.priority == 'high'
                                          ? Colors.red.shade400.withValues(
                                              alpha: 0.15,
                                            )
                                          : Colors.white,
                                      border: Border.all(
                                        color: form.priority == 'high'
                                            ? Colors.red.shade400
                                            : Colors.grey.withValues(
                                                alpha: 0.2,
                                              ),
                                        width: form.priority == 'high'
                                            ? 1.5
                                            : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade400,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'High',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: form.priority == 'high'
                                                    ? Colors.red.shade400
                                                    : Colors.grey.shade700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        /// Due Date Picker
                        _buildLabel(context, 'Due Date'),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: form.dueDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) {
                              controller.updateDueDate(picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.02),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.15),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  form.dueDate != null
                                      ? '${form.dueDate!.month}/${form.dueDate!.day}/${form.dueDate!.year}'
                                      : 'Select date (optional)',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: form.dueDate != null
                                            ? Colors.black87
                                            : Colors.grey.shade500,
                                      ),
                                ),
                                const Spacer(),
                                if (form.dueDate != null)
                                  GestureDetector(
                                    onTap: () => controller.updateDueDate(null),
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// Due Time Picker
                        _buildLabel(context, 'Due Time'),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: form.dueTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              controller.updateDueTime(picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.02),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.15),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  form.dueTime != null
                                      ? form.dueTime!.format(context)
                                      : 'Select time (optional)',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: form.dueTime != null
                                            ? Colors.black87
                                            : Colors.grey.shade500,
                                      ),
                                ),
                                const Spacer(),
                                if (form.dueTime != null)
                                  GestureDetector(
                                    onTap: () => controller.updateDueTime(null),
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// Attachment Picker
                        _buildLabel(context, 'Attachments'),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            if (form.attachments.length < 3) {
                              controller.addAttachment(
                                'document_${DateTime.now().millisecondsSinceEpoch}.pdf',
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.02),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.15),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add Attachment',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Text(
                                      'Images / documents (${form.attachments.length}/3)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.grey.shade500,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (form.attachments.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: form.attachments.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final file = entry.value;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
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
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () =>
                                          controller.removeAttachment(index),
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 24),

                        /// Reminder Toggle
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.02),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.15),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications_none,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Reminder',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Switch(
                                value: form.reminder,
                                onChanged: (_) => controller.toggleReminder(),
                                activeThumbColor: Colors.blue.shade500,
                              ),
                            ],
                          ),
                        ),

                        if (form.reminder) ...[
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime:
                                    form.reminderTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                controller.updateReminderTime(picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                border: Border.all(color: Colors.blue.shade200),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.alarm,
                                    size: 18,
                                    color: Colors.blue.shade600,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    form.reminderTime != null
                                        ? 'Remind at ${form.reminderTime!.format(context)}'
                                        : 'Set reminder time',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.blue.shade700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        /// Create Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: form.isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade500,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: form.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Create Task',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Bottom Spacing
              SliverToBoxAdapter(child: SizedBox(height: 160)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}
