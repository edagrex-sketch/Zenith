import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/task.dart';
import 'storage_service.dart';

class WidgetService {
  static const String _androidWidgetName = 'ZenithWidgetProvider';

  static const String _iosWidgetName = 'ZenithWidget';

  static Future<void> updateWidget() async {
    final List<Task> tasks = StorageService.getTasks()
        .where((t) => !t.isCompleted)
        .take(3)
        .toList();

    final tasksData = tasks
        .map(
          (t) => {
            'title': t.title,
            'time':
                '${t.dueDate.hour.toString().padLeft(2, '0')}:${t.dueDate.minute.toString().padLeft(2, '0')}',
          },
        )
        .toList();

    // Save data for the widget to read
    await HomeWidget.saveWidgetData<String>(
      'tasks_json',
      jsonEncode(tasksData),
    );

    // Trigger widget update
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: _iosWidgetName,
    );
  }
}
