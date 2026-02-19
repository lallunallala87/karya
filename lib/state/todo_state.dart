import "package:equatable/equatable.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:todo_bloc/model/todo.dart";

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoLoadingState extends TodoState {}

class TodoLoadedState extends TodoState {
  final List<Todo> todos;
  final List<Todo> completedTodos;
  final DateTime? selectedDate;
  final DateTime? selectedTime;
  final LatLng? selectedLocation;
  final String selectedLocationName;
  final Priority selectedPriority;
  final Set<String> dismissedIds;

  const TodoLoadedState({
    required this.todos,
    this.completedTodos = const [],
    this.selectedDate,
    this.selectedTime,
    this.selectedLocation,
    this.selectedLocationName = "",
    this.selectedPriority = Priority.low,
    this.dismissedIds = const {},
  });

  @override
  List<Object?> get props => [
    todos,
    completedTodos,
    selectedDate,
    selectedTime,
    selectedLocation,
    selectedLocationName,
    selectedPriority,
    dismissedIds,
  ];

  TodoLoadedState copyWith({
    List<Todo>? todos,
    List<Todo>? completedTodos,
    DateTime? selectedDate,
    DateTime? selectedTime,
    LatLng? selectedLocation,
    String? selectedLocationName,
    Priority? selectedPriority,
    Set<String>? dismissedIds,
    bool shouldClearDate = false,
    bool shouldClearTime = false,
    bool shouldClearLocation = false,
    bool shouldClearPriority = false,
  }) => TodoLoadedState(
    todos: todos ?? this.todos,
    completedTodos: completedTodos ?? this.completedTodos,
    selectedDate: shouldClearDate ? null : selectedDate ?? this.selectedDate,
    selectedTime: shouldClearTime ? null : selectedTime ?? this.selectedTime,
    selectedLocation: shouldClearLocation
        ? null
        : selectedLocation ?? this.selectedLocation,
    selectedLocationName: shouldClearLocation
        ? ""
        : selectedLocationName ?? this.selectedLocationName,
    selectedPriority: shouldClearPriority
        ? Priority.low
        : selectedPriority ?? this.selectedPriority,
    dismissedIds: dismissedIds ?? this.dismissedIds,
  );
}

class TodoErrorState extends TodoState {
  final String error;

  const TodoErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}
abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashNavigate extends SplashState {}

abstract class WelcomeState {}

class WelcomeInitial extends WelcomeState {}

class WelcomeNavigate extends WelcomeState {}
