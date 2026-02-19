import "package:xid/xid.dart";

enum Priority { critical, high, medium, low }

class Todo {
  final String id;
  final String title;
  final bool isChecked;
  final Priority priority;
  final DateTime taskDate;
  final DateTime taskTime;
  final String description;
  final double userLocation;

  Todo({
    required this.id,
    required this.title,
    required this.isChecked,
    required this.priority,
    required this.taskDate,
    required this.taskTime,
    required this.description,
    required this.userLocation,
  });

  factory Todo.create({
    required String title,
    required Priority priority,
    required String description,
    required DateTime taskDate,
    required DateTime taskTime,
  }) => Todo(
    id: Xid().toString(),
    // Unique ID using Xid
    title: title,
    isChecked: false,
    priority: priority,
    taskDate: taskDate,
    taskTime: taskTime,
    description: description,
    userLocation: 0.0,
  );

  Todo copyWith({
    String? id,
    String? title,
    bool? isChecked,
    Priority? priority,
    DateTime? taskDate,
    DateTime? taskTime,
    String? description,
    double? userLocation,
  }) => Todo(
    id: id ?? this.id,
    title: title ?? this.title,
    isChecked: isChecked ?? this.isChecked,
    priority: priority ?? this.priority,
    taskDate: taskDate ?? this.taskDate,
    taskTime: taskTime ?? this.taskTime,
    description: description ?? this.description,
    userLocation: userLocation ?? this.userLocation,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    "id": id,
    "title": title,
    "isChecked": isChecked ? 1 : 0,
    "priority": priority.name,
    "taskDate": taskDate.millisecondsSinceEpoch,
    "taskTime": taskTime.millisecondsSinceEpoch,
    "description": description,
    "userLocation": userLocation,
  };

  factory Todo.fromMap(Map<String, dynamic> map) => Todo(
    id: map["id"] as String? ?? "",
    title: map["title"] as String? ?? "",
    isChecked: (map["isChecked"] as int?) == 1,
    priority: Priority.values.firstWhere(
          (element) => element.name == map["priority"] as String?,
      orElse: () => Priority.low,
    ),
    taskDate: DateTime.fromMillisecondsSinceEpoch(map["taskDate"] as int? ?? 0),
    taskTime: DateTime.fromMillisecondsSinceEpoch(map["taskTime"] as int? ?? 0),
    description: map["description"] as String? ?? "",
    userLocation: map["userLocation"] as double? ?? 0.0,
  );

  @override
  String toString() =>
      "Todo(id: $id, title: $title, isChecked: $isChecked, priority: $priority, taskDate: $taskDate, taskTime: $taskTime, description: $description, userLocation: $userLocation)";

  @override
  bool operator ==(covariant Todo other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.isChecked == isChecked &&
        other.priority == priority &&
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
      priority.hashCode ^
      taskDate.hashCode ^
      taskTime.hashCode ^
      description.hashCode ^
      userLocation.hashCode;
}
