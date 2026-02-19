import "package:flutter/material.dart";

extension NullableDateTimeExtensions on DateTime? {
  String toTimeString() => this == null
        ? "Time"
        : "${this!.hour.toString().padLeft(2, '0')}:${this!.minute.toString().padLeft(2, '0')}";

  String toDateString() => this == null
        ? "Date"
        : "${this!.day.toString().padLeft(2, '0')}/${this!.month.toString().padLeft(2, '0')}";
}

extension DateTimePickerExtensions on DateTime {
  Future<TimeOfDay?> pickTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    return time;
  }

  Future<DateTime?> pickDate(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: this,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    // Return the selected date but keep the original time components
    if (date != null) {
      return DateTime(date.year, date.month, date.day, hour, minute);
    }
    return null;
  }
}
