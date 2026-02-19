import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:todo_bloc/bloc/todo_bloc.dart";
import "package:todo_bloc/event/todo_event.dart";
import "package:todo_bloc/model/todo.dart";

class TodoSnackBar {
  static showUndoSnackBar(BuildContext context, Todo todo, int index) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final todoBloc = context.read<TodoBloc>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${todo.title} removed.",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: "UNDO",
          textColor: const Color(0xFF6366F1),
          onPressed: () {
             todoBloc.add(UndoDeleteTodoEvent(todo, index));
          },
        ),
      ),
    );
  }
}
