import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D0F1A) : const Color(0xFFF3F4F6),
            ),
          ),
          // Glow effects
          if (isDark)
            Positioned(
              top: -150,
              left: -100,
              child: _buildGlowOrb(
                Colors.deepPurpleAccent.withOpacity(0.5),
                350,
              ),
            ),
          if (isDark)
            Positioned(
              bottom: 0,
              right: -100,
              child: _buildGlowOrb(Colors.blueAccent.withOpacity(0.4), 300),
            ),

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, ref),
                _buildHeader(context, ref),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: 100,
                  ),
                  sliver: tasks.isEmpty
                      ? _buildEmptyState()
                      : _buildTaskList(ref, tasks),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          children: [
            Text(
              'Fast Task 🚀',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              'Hi, Eduardo!',
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/logo.png'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 10),
              Icons.notifications_none_rounded,
              color: textColor.withOpacity(0.8),
            ),
          ],
        ).animate().fade(duration: 600.ms).slideY(begin: -0.2, end: 0),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning, Eduardo!',
              style: TextStyle(
                color: textColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'A sophisticated task management app',
              style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 14),
            ),
            const SizedBox(height: 30),
            Text(
              'My Tasks',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ).animate(delay: 200.ms).fade(duration: 600.ms).slideX(begin: -0.1, end: 0),
      ),
    );
  }

  Widget _buildTaskList(WidgetRef ref, List<Task> tasks) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildTaskCard(ref, task),
        ).animate(delay: (300 + (100 * index)).ms).fade(duration: 500.ms).slideY(begin: 0.2, end: 0);
      }, childCount: tasks.length),
    );
  }

  Widget _buildTaskCard(WidgetRef ref, Task task) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    // Compute progress
    double progress = task.isCompleted ? 1.0 : 0.0;
    if (task.subTasks.isNotEmpty && !task.isCompleted) {
      final completedSub = task.subTasks.where((st) => st.isCompleted).length;
      progress = completedSub / task.subTasks.length;
    }

    final isHigh = task.priority == 'High';
    final isDone = progress == 1.0;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          ref.read(taskListProvider.notifier).deleteTask(task.id),
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => ref
                          .read(taskListProvider.notifier)
                          .toggleTask(task.id),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isDone
                              ? const Color(0xFF8E2DE2)
                              : (isHigh ? Colors.blueAccent : Colors.white12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDone
                              ? Icons.check
                              : (isHigh ? Icons.check : Icons.circle_outlined),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                isDone
                                    ? 'Completed'
                                    : (progress > 0
                                          ? 'In Progress'
                                          : 'Pending'),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                              if (!isDone && task.subTasks.isEmpty) ...[
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    children: [
                                      Text(
                                        'REMINDER ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.alarm,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (task.subTasks.isNotEmpty)
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          color: isDone
                              ? const Color(0xFF8E2DE2)
                              : Colors.pinkAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                if (task.subTasks.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDone
                                ? [
                                    const Color(0xFF8E2DE2),
                                    const Color(0xFF4A00E0),
                                  ]
                                : [const Color(0xFF8E2DE2), Colors.pinkAccent],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: isDone
                                  ? const Color(0xFF8E2DE2).withOpacity(0.5)
                                  : Colors.pinkAccent.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Divider(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  height: 1,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.category,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Priority: ',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              task.priority,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Team: ',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Engineering',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              'DUE: ',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              DateFormat('EEE, h:mm a').format(task.dueDate),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (task.subTasks.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  ...task.subTasks.asMap().entries.map((e) {
                    return InkWell(
                      onTap: () => ref
                          .read(taskListProvider.notifier)
                          .toggleSubTask(task.id, e.key),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              e.value.isCompleted
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 16,
                              color: e.value.isCompleted
                                  ? Colors.green
                                  : Colors.white38,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              e.value.title,
                              style: TextStyle(
                                color: e.value.isCompleted
                                    ? Colors.white38
                                    : Colors.white70,
                                decoration: e.value.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://lottie.host/e70bf421-eb33-4f90-be87-e2a2202685c4/Q2cO1bO9XF.json',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.auto_awesome,
                size: 80,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No pending tasks.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
