import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../../core/theme/app_colors.dart';

class TaskListWidget extends StatefulWidget {
  const TaskListWidget({super.key});

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  final TextEditingController _taskController = TextEditingController();
  final FocusNode _taskFocusNode = FocusNode();

  @override
  void dispose() {
    _taskController.dispose();
    _taskFocusNode.dispose();
    super.dispose();
  }

  void _showEditDialog(
      BuildContext context, TaskViewModel viewModel, dynamic task) {
    final TextEditingController editController =
        TextEditingController(text: task.title);
    final FocusNode editFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            editFocusNode.unfocus();
          },
          child: AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text('Edit Task',
                style: TextStyle(color: AppColors.textPrimary)),
            content: TextField(
              controller: editController,
              focusNode: editFocusNode,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Task title',
                hintStyle: TextStyle(color: AppColors.textTertiary),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.textTertiary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed),
                onPressed: () async {
                  final newTitle = editController.text.trim();
                  final navigator = Navigator.of(context);
                  if (newTitle.isNotEmpty) {
                    final updated = task.copyWith(title: newTitle);
                    await viewModel.updateTask(updated);
                  }
                  navigator.pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      editController.dispose();
      editFocusNode.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, child) {
        final allTasks = viewModel.tasks;
        return GestureDetector(
          onTap: () {
            // Unfocus when tapping outside the text field
            _taskFocusNode.unfocus();
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Task input
                TextField(
                  controller: _taskController,
                  focusNode: _taskFocusNode,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'What are you working on?',
                    hintStyle: const TextStyle(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.darkGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      viewModel.addTask(value);
                      _taskController.clear();
                      _taskFocusNode.unfocus(); // Unfocus after submitting
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Add Task Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_taskController.text.trim().isNotEmpty) {
                        viewModel.addTask(_taskController.text);
                        _taskController.clear();
                        _taskFocusNode.unfocus(); // Unfocus after adding task
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Add Task',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Task List
                if (allTasks.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No tasks yet. Add one to get started!',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      ...allTasks.map((task) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.darkGrey,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.textTertiary
                                      .withValues(alpha: 0.06)),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      viewModel.toggleTaskCompletion(task.id),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: task.completed
                                          ? AppColors.primaryRed
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppColors.textSecondary),
                                    ),
                                    child: task.completed
                                        ? const Icon(Icons.check,
                                            size: 18, color: Colors.white)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: TextStyle(
                                      color: task.completed
                                          ? AppColors.textTertiary
                                          : AppColors.textPrimary,
                                      fontSize: 14,
                                      decoration: task.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                                if (task.pomodorosCompleted > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryRed
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.local_fire_department_rounded,
                                            size: 14,
                                            color: AppColors.primaryRed),
                                        const SizedBox(width: 6),
                                        Text('${task.pomodorosCompleted}',
                                            style: const TextStyle(
                                                color: AppColors.primaryRed,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                // Edit and Delete buttons
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.cardBackground,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        onPressed: () => _showEditDialog(
                                            context, viewModel, task),
                                        icon: const Icon(Icons.edit_outlined,
                                            color: AppColors.textSecondary,
                                            size: 18),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        onPressed: () =>
                                            viewModel.deleteTask(task.id),
                                        icon: const Icon(Icons.delete_outline,
                                            color: AppColors.error, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            '${viewModel.completedTasks.length}/${viewModel.tasks.length} completed',
                            style:
                                const TextStyle(color: AppColors.textTertiary)),
                      ),
                    ],
                  ),
              ],
            ),
          ), // Close Container
        ); // Close GestureDetector
      },
    );
  }
}
