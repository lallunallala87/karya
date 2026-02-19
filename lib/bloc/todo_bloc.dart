import "package:flutter_bloc/flutter_bloc.dart";
import "package:todo_bloc/event/todo_event.dart";
import "package:todo_bloc/model/todo.dart";
import "package:todo_bloc/services/notification_service.dart";
import "package:todo_bloc/state/todo_state.dart";
import "package:todo_bloc/utils/database_helper.dart";

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  TodoBloc() : super(TodoLoadingState()) {
    // 🔹 LOAD TODOS
    on<LoadTodosEvent>((event, emit) async {
      emit(TodoLoadingState());
      try {
        final todos = await _dbHelper.getTodos();
        emit(
          TodoLoadedState(
            todos: todos,
            selectedDate: null,
            selectedTime: null,
            selectedLocation: null,
            selectedLocationName: "",
          ),
        );
      } catch (e) {
        emit(TodoErrorState(error: 'Failed to load todos: $e'));
      }
    });

    // 🔹 ADD TODO
    on<AddTodoEvent>((event, emit) async {
      if (state is TodoLoadedState) {
        final currentState = state as TodoLoadedState;

        // Optimistically update UI
        final updatedTodos = [...currentState.todos, event.todo];
        emit(currentState.copyWith(todos: updatedTodos));

        try {
          await _dbHelper.insertTodo(event.todo);
          // 🔔 Schedule notification
          await NotificationService().scheduleNotification(event.todo);
        } catch (e) {
          emit(TodoErrorState(error: 'Failed to add todo to database: $e'));
        }
      }
    });

    // 🔹 DELETE TODO
    on<RemoveTodoEvent>((event, emit) async {
      if (state is TodoLoadedState) {
        final currentState = state as TodoLoadedState;

        // Optimistically update UI by emitting new state immediately
        final updatedTodos = currentState.todos
            .where((t) => t.id != event.todoId)
            .toList();

        emit(currentState.copyWith(todos: updatedTodos));

        try {
          await _dbHelper.deleteTodo(event.todoId);
          // 🔕 Cancel notification
          await NotificationService().cancelNotification(event.todoId);
        } catch (e) {
          // If deletion fails, we might want to reload or show an error
          // For now, let's keep it simple to fix the crash
          emit(TodoErrorState(error: 'Failed to remove todo from database: $e'));
        }
      }
    });
    on<ClearCompletedTodosEvent>((event, emit) {
      if (state is TodoLoadedState) {
        final currentState = state as TodoLoadedState;

        emit(currentState.copyWith(completedTodos: []));
      }
    });
    // 🔹 TOGGLE CHECK
    on<ToggleTodoEvent>((event, emit) async {
      if (state is TodoLoadedState) {
        final currentState = state as TodoLoadedState;
        try {
          final todoIndex = currentState.todos.indexWhere((t) => t.id == event.todoId);
          if (todoIndex == -1) return;

          final todo = currentState.todos[todoIndex];
          final updatedTodo = todo.copyWith(isChecked: !todo.isChecked);

          // Optimistically update UI
          final newTodos = List<Todo>.from(currentState.todos);
          newTodos[todoIndex] = updatedTodo;
          emit(currentState.copyWith(todos: newTodos));

          await _dbHelper.updateTodo(updatedTodo);

          // 🔔/🔕 Update notification
          if (updatedTodo.isChecked) {
            await NotificationService().cancelNotification(updatedTodo.id);
          } else {
            await NotificationService().scheduleNotification(updatedTodo);
          }
        } catch (e) {
          emit(TodoErrorState(error: 'Failed to toggle todo: $e'));
        }
      }
    });

    // 🔹 DATE
    on<UpdateTaskDateEvent>((event, emit) {
      if (state is TodoLoadedState) {
        emit((state as TodoLoadedState).copyWith(selectedDate: event.newDate));
      }
    });

    // 🔹 TIME
    on<UpdateTaskTimeEvent>((event, emit) {
      if (state is TodoLoadedState) {
        emit((state as TodoLoadedState).copyWith(selectedTime: event.newTime));
      }
    });

    // 🔹 LOCATION
    on<UpdateTaskLocationEvent>((event, emit) {
      if (state is TodoLoadedState) {
        emit(
          (state as TodoLoadedState).copyWith(
            selectedLocation: event.location,
            selectedLocationName: event.locationName,
          ),
        );
      }
    });

    // 🔹 PRIORITY
    on<UpdateTaskPriorityEvent>((event, emit) {
      if (state is TodoLoadedState) {
        emit(
          (state as TodoLoadedState).copyWith(selectedPriority: event.priority),
        );
      }
    });

    // 🔹 RESET DATE / TIME / LOCATION / PRIORITY
    on<ResetTaskDateTimeEvent>((event, emit) {
      if (state is TodoLoadedState) {
        emit(
          (state as TodoLoadedState).copyWith(
            shouldClearDate: true,
            shouldClearTime: true,
            shouldClearLocation: true,
            shouldClearPriority: true,
          ),
        );
      }
    });
    on<UpdateTodoEvent>((event, emit) async {
      if (state is TodoLoadedState) {
        final currentState = state as TodoLoadedState;

        // Optimistically update UI
        final updatedTodos = currentState.todos
            .map((t) => t.id == event.updatedTodo.id ? event.updatedTodo : t)
            .toList();

        emit(currentState.copyWith(todos: updatedTodos));

        try {
          await _dbHelper.updateTodo(event.updatedTodo);
          // 🔔 Reschedule notification
          await NotificationService().scheduleNotification(event.updatedTodo);
        } catch (e) {
          emit(TodoErrorState(error: 'Failed to update todo: $e'));
        }
      }
    });

    // 🔹 RESTORE TODO
    on<RestoreTodoEvent>((event, emit) async {
      if (state is TodoLoadedState) {
        final currentState = state as TodoLoadedState;
        try {
          await _dbHelper.insertTodo(event.todo);
          final newTodos = List<Todo>.from(currentState.todos);
          newTodos.insert(event.index, event.todo);
          emit(currentState.copyWith(todos: newTodos));
        } catch (e) {
          emit(TodoErrorState(error: 'Failed to restore todo: $e'));
        }
      }
    });

    // 🔹 ADD TO COMPLETED
    on<AddToCompletedEvent>((event, emit) {
      if (state is TodoLoadedState) {
        final currentState = state as TodoLoadedState;
        final newCompletedTodos = List<Todo>.from(currentState.completedTodos);
        newCompletedTodos.add(event.todo);
        emit(currentState.copyWith(completedTodos: newCompletedTodos));
      }
    });

    // 🔹 MARK AS DISMISSED
    on<MarkAsDismissedEvent>((event, emit) {
      if (state is TodoLoadedState) {
        final currentState = state as TodoLoadedState;
        final newDismissedIds = Set<String>.from(currentState.dismissedIds);
        newDismissedIds.add(event.todoId);
        emit(currentState.copyWith(dismissedIds: newDismissedIds));
      }
    });

    // 🔹 CLEAR DISMISSED
    on<ClearDismissedEvent>((event, emit) {
      if (state is TodoLoadedState) {
        final currentState = state as TodoLoadedState;
        emit(currentState.copyWith(dismissedIds: {}));
      }
    });
    on<UndoDeleteTodoEvent>((event, emit) async {
      if (state is TodoLoadedState) {
        final currentState = state as TodoLoadedState;

        // Ensure the restored item is NOT in dismissedIds
        final newDismissedIds = Set<String>.from(currentState.dismissedIds);
        newDismissedIds.remove(event.todo.id);

        // Always restore as unchecked to ensure it appears in active task list correctly
        final restoredTodo = event.todo.copyWith(isChecked: false);

        // Restore in active todos list safely
        final newTodos = List<Todo>.from(currentState.todos);

        // Avoid duplicate IDs in the list if undo is clicked multiple times rapidly
        if (newTodos.any((t) => t.id == restoredTodo.id)) return;

        // Safety check to prevent RangeError if list length changed
        if (event.index < 0) {
          newTodos.insert(0, restoredTodo);
        } else if (event.index >= newTodos.length) {
          newTodos.add(restoredTodo);
        } else {
          newTodos.insert(event.index, restoredTodo);
        }

        // Remove from completed list if it was moved there
        final newCompleted = currentState.completedTodos
            .where((t) => t.id != event.todo.id)
            .toList();

        // Emit state immediately for responsiveness
        emit(currentState.copyWith(
          todos: newTodos,
          completedTodos: newCompleted,
          dismissedIds: newDismissedIds,
        ));

        try {
          // Use insert with conflict algorithm if possible, or just insert
          await _dbHelper.insertTodo(restoredTodo);
        } catch (e) {
          // DB error logged, but UI is updated
          print("Undo DB Restore Error: $e");
        }
      }
    });

    on<CompleteTodoEvent>((event, emit) async {
      if (state is TodoLoadedState) {
        final currentState = state as TodoLoadedState;

        final completedTodo = event.todo.copyWith(isChecked: true);
        final newCompletedTodos = List<Todo>.from(currentState.completedTodos);
        newCompletedTodos.add(completedTodo);

        final updatedTodos = currentState.todos
            .where((t) => t.id != event.todo.id)
            .toList();

        // Atomic update to prevent Dismissible issues
        emit(currentState.copyWith(
          todos: updatedTodos,
          completedTodos: newCompletedTodos,
        ));

        try {
          await _dbHelper.deleteTodo(event.todo.id);
        } catch (e) {
          emit(TodoErrorState(error: 'Failed to complete todo: $e'));
        }
      }
    });
  }
}

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>((event, emit) async {
      await Future.delayed(const Duration(seconds: 2));
      emit(SplashNavigate());
    });
  }
}

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc() : super(WelcomeInitial()) {
    on<GetStartedPressed>(_onGetStartedPressed);
  }

  void _onGetStartedPressed(
      GetStartedPressed event,
      Emitter<WelcomeState> emit,
      ) {
    emit(WelcomeNavigate());
  }
}
