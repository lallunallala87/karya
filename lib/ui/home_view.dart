import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:todo_bloc/bloc/todo_bloc.dart";
import "package:todo_bloc/event/todo_event.dart";
import "package:todo_bloc/model/todo.dart";
import "package:todo_bloc/services/notification_service.dart";
import "package:todo_bloc/state/todo_state.dart";
import "package:todo_bloc/ui/widgets/date_formatter.dart";
import "package:todo_bloc/ui/widgets/modal_bottomsheet.dart";
import "package:todo_bloc/ui/widgets/todo_snackbar.dart";
import "package:todo_bloc/utils/app_colors.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService = NotificationService();
      notificationService.onDueTodos = _showDueTodoDialog;
      notificationService.startCheckingForDueTodos();
    });
  }

  Color getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return AppColors.priorityLow;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.critical:
        return AppColors.priorityCritical;
      default:
        return AppColors.priorityHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("KARYA"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton.filledTonal(
              onPressed: () => openTaskDoneDialog(context),
              icon: const Icon(Icons.history_rounded),
            ),
          ),
        ],
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoLoadedState) {
            final todos = state.todos
                .where((t) => !state.dismissedIds.contains(t.id))
                .toList();
            
            if (todos.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTaskCard(context, todo, index),
                );
              },
            );
          } else if (state is TodoErrorState) {
            return Center(child: Text("Error: ${state.error}"));
          }
          return _buildEmptyState();
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => ModalBottomsheet.showTaskModal(context: context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          label: const Text(
            "Add Task",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 80,
            color: Colors.grey.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            "All caught up!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add a new task to get started.",
            style: TextStyle(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Todo todo, int index) {
    final priorityColor = getPriorityColor(todo.priority);
    
    return Dismissible(
      key: ValueKey(todo.id),
      background: _buildDismissBackground(
        color: const Color(0xFF6366F1),
        icon: Icons.edit_rounded,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildDismissBackground(
        color: const Color(0xFFEF4444),
        icon: Icons.delete_outline_rounded,
        alignment: Alignment.centerRight,
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          context.read<TodoBloc>().add(CompleteTodoEvent(todo, index));
          TodoSnackBar.showUndoSnackBar(context, todo, index);
        } else {
          ModalBottomsheet.showTaskModal(context: context, todoToEdit: todo);
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          ModalBottomsheet.showTaskModal(context: context, todoToEdit: todo);
          return false;
        }
        return true;
      },
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => ModalBottomsheet.showTaskModal(context: context, todoToEdit: todo),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: todo.isChecked,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: (value) {
                      context.read<TodoBloc>().add(ToggleTodoEvent(todo.id));
                      if (value ?? false) {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          context.read<TodoBloc>().add(CompleteTodoEvent(todo, index));
                          TodoSnackBar.showUndoSnackBar(context, todo, index);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decoration: todo.isChecked ? TextDecoration.lineThrough : null,
                          color: todo.isChecked ? Colors.grey : const Color(0xFF1E293B),
                        ),
                      ),
                      if (todo.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey.shade500, // Changed from Colors.slate.shade500
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildShortChip(
                            icon: Icons.flag_rounded,
                            label: todo.priority.name.toUpperCase(),
                            color: priorityColor,
                          ),
                          const SizedBox(width: 8),
                          _buildShortChip(
                            icon: Icons.calendar_today_rounded,
                            label: "${todo.taskDate.toDateString()} • ${todo.taskTime.toTimeString()}",
                            color: const Color(0xFF6366F1),
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
      ),
    );
  }

  Widget _buildShortChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      child: Icon(icon, color: Colors.white),
    );
  }

  void _showDueTodoDialog(List<Todo> dueTodos) {
    for (Todo todo in dueTodos) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text("Due Todo Reminder"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Title: ${todo.title}"),
                if (todo.description.trim().isNotEmpty)
                  Text("Description: ${todo.description}"),
                Text("Priority: ${todo.priority.name}"),
                Text(
                  "Due: ${todo.taskDate.toDateString()} at ${todo.taskTime.toTimeString()}",
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("Dismiss"),
              ),
            ],
          ),
      );
    }
  }

  void openTaskDoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoadedState) {
            final completedTodos = state.completedTodos;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text(
                "Completed Tasks",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 400,
                child: completedTodos.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text("No completed tasks yet", style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
                    : ListView.separated(
                  itemCount: completedTodos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
                  itemBuilder: (context, index) {
                    final todo = completedTodos[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.priorityLow.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, size: 18, color: AppColors.priorityLow),
                      ),
                      title: Text(
                        todo.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: todo.description.trim().isNotEmpty
                          ? Text(todo.description, maxLines: 1, overflow: TextOverflow.ellipsis)
                          : null,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Close"),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    context.read<TodoBloc>().add(ClearCompletedTodosEvent());
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("Clear History"),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
