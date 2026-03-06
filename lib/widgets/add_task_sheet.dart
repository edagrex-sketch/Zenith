import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subTaskController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  String _selectedCategory = 'General';
  String _selectedPriority = 'Medium';
  String _selectedRecurrence = 'None';
  final List<SubTask> _subTasks = [];

  // Voice Recognition
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  final Map<String, Color> _categoryColors = {
    'General': Colors.grey,
    'Trabajo': Colors.blue,
    'Personal': Colors.green,
    'Salud': Colors.red,
    'Idea': Colors.amber,
  };

  final Map<String, IconData> _categoryIcons = {
    'General': Icons.list,
    'Trabajo': Icons.work,
    'Personal': Icons.person,
    'Salud': Icons.favorite,
    'Idea': Icons.lightbulb,
  };

  Future<void> _listen() async {
    if (!_isListening) {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'),
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) => setState(() {
              _titleController.text = val.recognizedWords;
            }),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1E).withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTitleField(),
              const SizedBox(height: 15),
              _buildTextField(_descController, 'Descripción (opcional)', 3),
              const SizedBox(height: 20),
              _buildSectionTitle('Categoría'),
              const SizedBox(height: 10),
              _buildCategorySelector(),
              const SizedBox(height: 20),
              _buildSectionTitle('Prioridad y Repetir'),
              const SizedBox(height: 10),
              _buildOptionsRow(),
              const SizedBox(height: 20),
              _buildSectionTitle('Fecha y Hora'),
              const SizedBox(height: 10),
              _buildDateTimeRow(),
              const SizedBox(height: 25),
              _buildSectionTitle('Sub-tareas'),
              const SizedBox(height: 10),
              _buildSubTasksSection(),
              const SizedBox(height: 30),
              _buildCreateButton(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Nueva Aspiración',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(_titleController, 'Título de la tarea', 1),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _listen,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isListening
                  ? Colors.redAccent.withOpacity(0.2)
                  : Colors.cyanAccent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isListening
                    ? Colors.redAccent
                    : Colors.cyanAccent.withOpacity(0.3),
              ),
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.redAccent : Colors.cyanAccent,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    int lines,
  ) {
    return TextField(
      controller: controller,
      maxLines: lines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categoryColors.keys.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat),
              selectedColor: _categoryColors[cat]?.withOpacity(0.3),
              backgroundColor: Colors.white.withOpacity(0.05),
              labelStyle: TextStyle(
                color: isSelected ? _categoryColors[cat] : Colors.white60,
              ),
              avatar: Icon(
                _categoryIcons[cat],
                size: 16,
                color: isSelected ? _categoryColors[cat] : Colors.white24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: _selectedPriority,
            items: ['Low', 'Medium', 'High'],
            icon: Icons.flag_outlined,
            onChanged: (val) => setState(() => _selectedPriority = val!),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildDropdown(
            value: _selectedRecurrence,
            items: ['None', 'Daily', 'Weekly'],
            icon: Icons.repeat,
            onChanged: (val) => setState(() => _selectedRecurrence = val!),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A2E),
          icon: Icon(icon, color: Colors.white24, size: 20),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white70)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.calendar_today,
            label: DateFormat('d MMM').format(_selectedDate),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null)
                setState(
                  () => _selectedDate = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    _selectedDate.hour,
                    _selectedDate.minute,
                  ),
                );
            },
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildActionButton(
            icon: Icons.access_time,
            label: DateFormat('HH:mm').format(_selectedDate),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_selectedDate),
              );
              if (picked != null)
                setState(
                  () => _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    picked.hour,
                    picked.minute,
                  ),
                );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTasksSection() {
    return Column(
      children: [
        ..._subTasks.map(
          (st) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.subdirectory_arrow_right,
              color: Colors.white24,
            ),
            title: Text(
              st.title,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () => setState(() => _subTasks.remove(st)),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _subTaskController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Añadir sub-paso...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) => _addSubTask(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.cyanAccent),
              onPressed: _addSubTask,
            ),
          ],
        ),
      ],
    );
  }

  void _addSubTask() {
    if (_subTaskController.text.isNotEmpty) {
      setState(() {
        _subTasks.add(SubTask(title: _subTaskController.text));
        _subTaskController.clear();
      });
    }
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (_titleController.text.isNotEmpty) {
            final newTask = Task(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              description: _descController.text,
              dueDate: _selectedDate,
              category: _selectedCategory,
              priority: _selectedPriority,
              recurrence: _selectedRecurrence,
              subTasks: _subTasks,
            );
            ref.read(taskListProvider.notifier).addTask(newTask);
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 20,
          shadowColor: Colors.deepPurple.withOpacity(0.5),
        ),
        child: const Text(
          'Comenzar Misión',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
