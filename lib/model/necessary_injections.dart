import 'dart:convert';

import "package:todo_bloc/model/todo.dart";

class NecessaryInjections {
  final String id;
  final String title;
  final bool isChecked;
  final DateTime taskDate;
  final DateTime taskTime;
  final String description;
  final double userLocation;

  NecessaryInjections({
    required this.id,
    required this.title,
    required this.isChecked,
    required this.taskDate,
    required this.taskTime,
    required this.description,
    required this.userLocation,
  });

  NecessaryInjections copyWith({
    String? id,
    String? title,
    bool? isChecked,
    Priority? priority,
    DateTime? taskDate,
    DateTime? taskTime,
    String? description,
    double? userLocation,
  }) => NecessaryInjections(
    id: id ?? this.id,
    title: title ?? this.title,
    isChecked: isChecked ?? this.isChecked,
    taskDate: taskDate ?? this.taskDate,
    taskTime: taskTime ?? this.taskTime,
    description: description ?? this.description,
    userLocation: userLocation ?? this.userLocation,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'isChecked': isChecked,
    'taskDate': taskDate.millisecondsSinceEpoch,
    'taskTime': taskTime.millisecondsSinceEpoch,
    'description': description,
    'userLocation': userLocation,
  };

  factory NecessaryInjections.fromMap(Map<String, dynamic> map) =>
      NecessaryInjections(
        id: map['id'] as String,
        title: map['title'] as String,
        isChecked: map['isChecked'] as bool,
        taskDate: DateTime.fromMillisecondsSinceEpoch(map['taskDate'] as int),
        taskTime: DateTime.fromMillisecondsSinceEpoch(map['taskTime'] as int),
        description: map['description'] as String,
        userLocation: map['userLocation'] as double,
      );

  String toJson() => json.encode(toMap());

  factory NecessaryInjections.fromJson(String source) =>
      NecessaryInjections.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'NecessaryInjections(id: $id, title: $title, isChecked: $isChecked, taskDate: $taskDate, taskTime: $taskTime, description: $description, userLocation: $userLocation)';

  @override
  bool operator ==(covariant NecessaryInjections other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.isChecked == isChecked &&
        other.taskDate == taskDate &&
        other.taskTime == taskTime &&
        other.description == description &&
        other.userLocation == userLocation;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      isChecked.hashCode ^
      taskDate.hashCode ^
      taskTime.hashCode ^
      description.hashCode ^
      userLocation.hashCode;
}
