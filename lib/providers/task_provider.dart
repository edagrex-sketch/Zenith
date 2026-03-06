import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

final taskListProvider = NotifierProvider<TaskListNotifier, List<Task>>(
  TaskListNotifier.new,
);

class TaskListNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    return StorageService.getTasks();
  }

  Future<void> addTask(Task task) async {
    await StorageService.addTask(task);
    if (!task.isCompleted) {
      await NotificationService.scheduleTaskReminder(task);
    }
    await WidgetService.updateWidget();
    ref.invalidateSelf();
  }

  Future<void> toggleTask(String id) async {
    final taskIndex = state.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      final task = state[taskIndex];
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await StorageService.updateTask(updatedTask);

      if (updatedTask.isCompleted) {
        await NotificationService.cancelReminder(id);

        // Handle recurrence
        if (task.recurrence != 'None') {
          final nextDate = _calculateNextDate(task.dueDate, task.recurrence!);
          final nextTask = Task(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: task.title,
            description: task.description,
            dueDate: nextDate,
            category: task.category,
            priority: task.priority,
            recurrence: task.recurrence,
            subTasks: task.subTasks
                .map((st) => SubTask(title: st.title, isCompleted: false))
                .toList(),
          );
          await addTask(nextTask);
        }
      } else {
        await NotificationService.scheduleTaskReminder(updatedTask);
      }

      await WidgetService.updateWidget();
      ref.invalidateSelf();
    }
  }

  DateTime _calculateNextDate(DateTime current, String recurrence) {
    if (recurrence == 'Daily') {
      return current.add(const Duration(days: 1));
    } else if (recurrence == 'Weekly') {
      return current.add(const Duration(days: 7));
    }
    return current;
  }

  Future<void> toggleSubTask(String taskId, int subTaskIndex) async {
    final taskIndex = state.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = state[taskIndex];
      final updatedSubTasks = List<SubTask>.from(task.subTasks);
      updatedSubTasks[subTaskIndex].isCompleted =
          !updatedSubTasks[subTaskIndex].isCompleted;

      final updatedTask = task.copyWith(subTasks: updatedSubTasks);
      await StorageService.updateTask(updatedTask);
      ref.invalidateSelf();
    }
  }

  Future<void> deleteTask(String id) async {
    await StorageService.deleteTask(id);
    await NotificationService.cancelReminder(id);
    await WidgetService.updateWidget();
    ref.invalidateSelf();
  }
}
