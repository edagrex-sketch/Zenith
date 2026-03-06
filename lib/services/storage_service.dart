import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class StorageService {
  static const String taskBoxName = 'tasks_v2';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SubTaskAdapter());
    Hive.registerAdapter(TaskAdapter());
    try {
      await Hive.openBox<Task>(taskBoxName);
    } catch (e) {
      print('Hive Error, trying to clear box: $e');
      await Hive.deleteBoxFromDisk(taskBoxName);
      await Hive.openBox<Task>(taskBoxName);
    }
  }

  static Future<void> addTask(Task task) async {
    final box = Hive.box<Task>(taskBoxName);
    await box.put(task.id, task);
  }

  static Future<void> updateTask(Task task) async {
    final box = Hive.box<Task>(taskBoxName);
    await box.put(task.id, task);
  }

  static Future<void> deleteTask(String id) async {
    final box = Hive.box<Task>(taskBoxName);
    await box.delete(id);
  }

  static List<Task> getTasks() {
    final box = Hive.box<Task>(taskBoxName);
    return box.values.toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  static int calculateStreak() {
    final box = Hive.box<Task>(taskBoxName);
    final tasks = box.values.where((t) => t.isCompleted).toList();
    if (tasks.isEmpty) return 0;

    final completedDates =
        tasks
            .map(
              (t) => DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // Descending

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime currentCheck = DateTime(today.year, today.month, today.day);

    // If no tasks today, check if there was one yesterday to keep streak alive
    bool taskToday = completedDates.any(
      (d) => d.isAtSameMomentAs(currentCheck),
    );
    if (!taskToday) {
      currentCheck = currentCheck.subtract(const Duration(days: 1));
    }

    for (var date in completedDates) {
      if (date.isAtSameMomentAs(currentCheck)) {
        streak++;
        currentCheck = currentCheck.subtract(const Duration(days: 1));
      } else if (date.isBefore(currentCheck)) {
        break;
      }
    }
    return streak;
  }
}
