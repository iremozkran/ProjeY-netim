import 'package:flutter/material.dart';
import 'package:proje_takip/models/task.dart';
import 'package:proje_takip/services/db_task_service.dart';
import 'package:proje_takip/utils/custom_container.dart';
import 'package:proje_takip/utils/responsive.dart';

class EmployeeTasksPage extends StatefulWidget {
  final int employeeId;

  const EmployeeTasksPage({super.key, required this.employeeId});

  @override
  State<EmployeeTasksPage> createState() => _EmployeeTasksPageState();
}

class _EmployeeTasksPageState extends State<EmployeeTasksPage> {
  late Future<List<Task>> _tasks;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = DbTaskService().getEmployeeHistoryTask(widget.employeeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamamlanan Görevler'),
      ),
      body: Padding(
        padding: Responsive.pagePadding(context),
        child: CustomContainer(
          child: FutureBuilder<List<Task>>(
            future: _tasks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No tasks found.'));
              } else {
                final tasks = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Görev Adı: ${task.name}',
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Proje: ${task.projectId}',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Tamamlandı',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Başlangıç Tarihi: ${task.startDate}',
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                                Text(
                                  'Bitiş Tarihi: ${task.endDate}',
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
