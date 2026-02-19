import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:geocoding/geocoding.dart';
import "package:todo_bloc/bloc/todo_bloc.dart";
import "package:todo_bloc/event/todo_event.dart";
import "package:todo_bloc/model/todo.dart";
import "package:todo_bloc/state/todo_state.dart";
import "package:todo_bloc/ui/widgets/date_formatter.dart";
import "package:todo_bloc/ui/widgets/location_picker.dart";

class TaskChips extends StatelessWidget {
  const TaskChips({super.key});

  Future<String> _getLocationName(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final sub = place.subLocality ?? '';
        final city = place.locality ?? '';
        if (sub.isNotEmpty && sub != city) {
          return "$sub, $city";
        }
        return city.isNotEmpty ? city : "Location";
      }
    } catch (e) {
      debugPrint("Geocoding failed: $e");
    }
    return "Location";
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    child: Row(
      children: [
        BlocBuilder<TodoBloc, TodoState>(
          key: const ValueKey('date_time_chip'),
          builder: (context, state) {
            if (state is! TodoLoadedState) return const SizedBox.shrink();

            final dateLabel = state.selectedDate?.toDateString() ?? "Set Date";
            final timeLabel = state.selectedTime?.toTimeString() ?? "Set Time";
            final isSet = state.selectedDate != null || state.selectedTime != null;

            return ActionChip(
              avatar: Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: isSet ? Colors.white : const Color(0xFF6366F1),
              ),
              label: Text("$dateLabel • $timeLabel"),
              backgroundColor: isSet ? const Color(0xFF6366F1) : Colors.white,
              labelStyle: TextStyle(
                color: isSet ? Colors.white : const Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: isSet ? Colors.transparent : const Color(0xFF6366F1).withOpacity(0.2),
              ),
              onPressed: () async {
                if (state.selectedDate == null) {
                  final date = await DateTime.now().pickDate(context);
                  if (date != null) context.read<TodoBloc>().add(UpdateTaskDateEvent(date));
                } else if (state.selectedTime == null) {
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (time != null) {
                    final d = state.selectedDate!;
                    context.read<TodoBloc>().add(UpdateTaskTimeEvent(DateTime(d.year, d.month, d.day, time.hour, time.minute)));
                  }
                } else {
                  context.read<TodoBloc>().add(ResetTaskDateTimeEvent());
                }
              },
            );
          },
        ),
        const SizedBox(width: 12),
        BlocBuilder<TodoBloc, TodoState>(
          key: const ValueKey('priority_chip'),
          builder: (context, state) {
            if (state is! TodoLoadedState) return const SizedBox.shrink();

            final priorityText = state.selectedPriority.name.toUpperCase();
            
            return ActionChip(
              avatar: const Icon(Icons.flag_rounded, size: 16, color: Color(0xFF6366F1)),
              label: Text("Priority: $priorityText"),
              backgroundColor: Colors.white,
              labelStyle: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.2)),
              onPressed: () async {
                final Priority? result = await showDialog<Priority>(
                  context: context,
                  builder: (dialogContext) {
                    Priority temp = state.selectedPriority;
                    return StatefulBuilder(
                      builder: (_, setState) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          title: const Text("Select Priority"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: Priority.values.map((p) => RadioListTile(
                              title: Text(p.name.toUpperCase()),
                              value: p,
                              groupValue: temp,
                              onChanged: (value) => setState(() => temp = value!),
                            )).toList(),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
                            FilledButton(onPressed: () => Navigator.pop(dialogContext, temp), child: const Text("Apply")),
                          ],
                        );
                      },
                    );
                  },
                );
                if (result != null) context.read<TodoBloc>().add(UpdateTaskPriorityEvent(result));
              },
            );
          },
        ),
        const SizedBox(width: 12),
        BlocBuilder<TodoBloc, TodoState>(
          key: const ValueKey('location_chip'),
          builder: (context, state) {
            final isLocationSet = state is TodoLoadedState && state.selectedLocation != null;
            return ActionChip(
              avatar: const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF6366F1)),
              label: Text(isLocationSet ? "Change Location" : "Add Location"),
              backgroundColor: Colors.white,
              labelStyle: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.2)),
              onPressed: () async {
                final LatLng? pickedLocation = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LocationPickerScreen()),
                );
                if (pickedLocation != null) {
                  final name = await _getLocationName(pickedLocation);
                  context.read<TodoBloc>().add(UpdateTaskLocationEvent(pickedLocation, name));
                }
              },
            );
          },
        ),
        const SizedBox(width: 24),
      ],
    ),
  );
}
