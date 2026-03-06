import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class SubTask extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  SubTask({required this.title, this.isCompleted = false});
}

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  String priority; // 'Low', 'Medium', 'High'

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String category; // 'General', 'Trabajo', 'Personal', 'Salud', 'Idea'

  @HiveField(8)
  List<SubTask> subTasks;

  @HiveField(9)
  String? recurrence; // 'None', 'Daily', 'Weekly'

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 'Medium',
    DateTime? createdAt,
    this.category = 'General',
    List<SubTask>? subTasks,
    this.recurrence = 'None',
  }) : createdAt = createdAt ?? DateTime.now(),
       subTasks = subTasks ?? [];

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    String? priority,
    String? category,
    List<SubTask>? subTasks,
    String? recurrence,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      category: category ?? this.category,
      subTasks: subTasks ?? this.subTasks,
      recurrence: recurrence ?? this.recurrence,
    );
  }
}
