import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:todo_bloc/model/todo.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> scheduleNotification(Todo todo) async {
    if (todo.isChecked) return;

    // Combine taskDate and taskTime for accurate scheduling
    DateTime scheduleTime = DateTime(
      todo.taskDate.year,
      todo.taskDate.month,
      todo.taskDate.day,
      todo.taskTime.hour,
      todo.taskTime.minute,
    );

    // Don't schedule if the time is more than a minute in the past
    // We allow a 5-second grace period for "current time" scheduling
    if (scheduleTime.isBefore(DateTime.now().subtract(const Duration(seconds: 5)))) {
      print('⚠️ Cannot schedule for the past: $scheduleTime');
      return;
    }

    String channelKey = _getChannelKeyForPriority(todo.priority);

    print('🔔 Attempting to schedule notification: ${todo.title} at $scheduleTime');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: todo.id.hashCode.abs().remainder(100000),
        channelKey: channelKey,
        title: todo.title,
        body: todo.description.isNotEmpty ? todo.description : 'Task Reminder',
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DONE',
          label: 'Mark Done',
          actionType: ActionType.Default,
        ),
      ],
      schedule: NotificationCalendar.fromDate(
        date: scheduleTime,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
    print('📅 Successfully scheduled notification for ${todo.title} at $scheduleTime');
  }

  Future<void> cancelNotification(String todoId) async {
    await AwesomeNotifications().cancel(todoId.hashCode.abs().remainder(100000));
  }

  String _getChannelKeyForPriority(Priority priority) {
    switch (priority) {
      case Priority.critical:
      case Priority.high:
        return 'high_priority_v4';
      case Priority.medium:
        return 'medium_priority_v4';
      case Priority.low:
        return 'low_priority_v4';
      default:
        return 'low_priority_v4';
    }
  }

  // Deprecated timer-based methods kept for compatibility with current HomeView if not updated yet
  void startCheckingForDueTodos() {}
  void stopCheckingForDueTodos() {}
  set onDueTodos(Function(List<Todo>)? value) {}
}

