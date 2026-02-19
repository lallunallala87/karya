import "package:flutter/material.dart";
import "package:intl/intl.dart";

extension NullableDateTimeExtensions on DateTime? {
  String toTimeString() {
    if (this == null) return "Time";
    return DateFormat.Hm().format(this!);
  }

  String toDateString() {
    if (this == null) return "Date";
    return DateFormat("dd/MM").format(this!);
  }
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
    if (date != null) {
      return DateTime(date.year, date.month, date.day, hour, minute);
    }
    return null;
  }
}
