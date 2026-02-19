import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:todo_bloc/bloc/todo_bloc.dart";
import "package:todo_bloc/event/todo_event.dart";
import "package:todo_bloc/model/todo.dart";
import "package:todo_bloc/state/todo_state.dart";
import "package:todo_bloc/ui/widgets/task_chips.dart";

class ModalBottomsheet {
  static void showTaskModal({required BuildContext context, Todo? todoToEdit}) {
    final isEditing = todoToEdit != null;
    final titleController = TextEditingController(
      text: isEditing ? todoToEdit.title : "",
    );
    final descriptionController = TextEditingController(
      text: isEditing ? todoToEdit.description : "",
    );
    final todoBloc = context.read<TodoBloc>();
    if (isEditing) {
      todoBloc.add(UpdateTaskDateEvent(todoToEdit.taskDate));
      todoBloc.add(UpdateTaskTimeEvent(todoToEdit.taskTime));
    } else {
      todoBloc.add(ResetTaskDateTimeEvent());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext modalContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? "Edit Task" : "New Task",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      maxLength: 30,
                      controller: titleController,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: "What needs to be done?",
                        prefixIcon: const Icon(Icons.title_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Add details...",
                        prefixIcon: const Icon(Icons.description_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const TaskChips(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: const Color(0xFF6366F1),
                        ),
                        onPressed: () {
                          final state = todoBloc.state;
                          DateTime selectedDatePart = DateTime.now();
                          DateTime selectedTimePart = DateTime.now();

                          if (state is TodoLoadedState) {
                            selectedDatePart = state.selectedDate ?? DateTime.now();
                            selectedTimePart = state.selectedTime ?? DateTime.now();
                          }

                          final combinedDateTime = DateTime(
                            selectedDatePart.year,
                            selectedDatePart.month,
                            selectedDatePart.day,
                            selectedTimePart.hour,
                            selectedTimePart.minute,
                          );

                          if (titleController.text.trim().isNotEmpty) {
                            final selectedPriority = state is TodoLoadedState
                                ? state.selectedPriority
                                : Priority.low;
                            if (isEditing) {
                              final updatedTodo = todoToEdit!.copyWith(
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                taskDate: combinedDateTime,
                                taskTime: combinedDateTime,
                                priority: selectedPriority,
                              );
                              todoBloc.add(UpdateTodoEvent(updatedTodo));
                            } else {
                              final newTodo = Todo.create(
                                title: titleController.text.trim(),
                                priority: selectedPriority,
                                description: descriptionController.text.trim(),
                                taskDate: combinedDateTime,
                                taskTime: combinedDateTime,
                              );
                              todoBloc.add(AddTodoEvent(newTodo));
                            }
                          }
                          Navigator.pop(modalContext);
                        },
                        child: Text(
                          isEditing ? "Save Changes" : "Create Task",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      todoBloc.add(ResetTaskDateTimeEvent());
    });
  }
}
