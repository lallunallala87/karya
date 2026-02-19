import "package:equatable/equatable.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:todo_bloc/model/todo.dart";

abstract class TodoEvent extends Equatable {
  @override
  List<Object> get props => [];
}
abstract class SplashEvent {}

class SplashStarted extends SplashEvent {}

abstract class WelcomeEvent {}

class GetStartedPressed extends WelcomeEvent {}

class ClearCompletedTodosEvent extends TodoEvent {}

class AddTodoEvent extends TodoEvent {
  final Todo todo;

  AddTodoEvent(this.todo);

  @override
  List<Object> get props => [todo];
}

class RemoveTodoEvent extends TodoEvent {
  final String todoId;
  final int index;

  RemoveTodoEvent(this.todoId, this.index);

  @override
  List<Object> get props => [todoId, index];
}

class ToggleTodoEvent extends TodoEvent {
  final String todoId;

  ToggleTodoEvent(this.todoId);

  @override
  List<Object> get props => [todoId];
}

class LoadTodosEvent extends TodoEvent {}

class UpdateTaskDateEvent extends TodoEvent {
  final DateTime newDate;

  UpdateTaskDateEvent(this.newDate);

  @override
  List<Object> get props => [newDate];
}

class UpdateTaskTimeEvent extends TodoEvent {
  final DateTime newTime;

  UpdateTaskTimeEvent(this.newTime);

  @override
  List<Object> get props => [newTime];
}

class RestoreTodoEvent extends TodoEvent {
  final Todo todo;
  final int index;

  RestoreTodoEvent(this.todo, this.index);

  @override
  List<Object> get props => [todo, index];
}

class UpdateTodoEvent extends TodoEvent {
  final Todo updatedTodo;

  UpdateTodoEvent(this.updatedTodo);

  @override
  List<Object> get props => [updatedTodo];
}

class ResetTaskDateTimeEvent extends TodoEvent {}

class UpdateTaskLocationEvent extends TodoEvent {
  final LatLng location;
  final String locationName;

  UpdateTaskLocationEvent(this.location, this.locationName);

  @override
  List<Object> get props => [location, locationName];
}

class UpdateTaskPriorityEvent extends TodoEvent {
  final Priority priority;

  UpdateTaskPriorityEvent(this.priority);

  @override
  List<Object> get props => [priority];
}

class ResetTaskPriorityEvent extends TodoEvent {}

class AddToCompletedEvent extends TodoEvent {
  final Todo todo;

  AddToCompletedEvent(this.todo);

  @override
  List<Object> get props => [todo];
}

class MarkAsDismissedEvent extends TodoEvent {
  final String todoId;

  MarkAsDismissedEvent(this.todoId);

  @override
  List<Object> get props => [todoId];
}

class ClearDismissedEvent extends TodoEvent {}

class UndoDeleteTodoEvent extends TodoEvent {
  final Todo todo;
  final int index;

  UndoDeleteTodoEvent(this.todo, this.index);

  @override
  List<Object> get props => [todo, index];
}

class CompleteTodoEvent extends TodoEvent {
  final Todo todo;
  final int index;

  CompleteTodoEvent(this.todo, this.index);

  @override
  List<Object> get props => [todo, index];
}
