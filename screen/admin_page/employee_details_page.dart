import 'package:flutter/material.dart';
import 'package:proje_takip/models/employee.dart';
import 'package:proje_takip/models/task.dart';
import 'package:proje_takip/services/db_employee_service.dart';
import 'package:proje_takip/services/db_task_service.dart';
import 'package:proje_takip/utils/app_dialogs.dart';
import 'package:proje_takip/utils/app_elevated_button.dart';
import 'package:proje_takip/utils/custom_container.dart';
import 'package:proje_takip/utils/responsive.dart';

class EmployeeDetailsPage extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailsPage({required this.employee, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${employee.name} Adlı Çalışan Detayları'),
      ),
      body: Padding(
        padding: Responsive.pagePadding(context),
        child: CustomContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Çalışan Bilgileri',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.indigo[800],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Adı: ${employee.name}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'ID: ${employee.id}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Görevler:',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.indigo[700],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Expanded(
                child: FutureBuilder<List<Task>>(
                  future: DbTaskService().getTasksByEmployeeId(employee.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Hata: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final tasks = snapshot.data!;
                      if (tasks.isEmpty) {
                        return Center(child: Text('Henüz görev atanmadı.'));
                      }

                      final completedTasks = tasks
                          .where((task) => task.status == 'Tamamlandı')
                          .toList();
                      final inProgressTasks = tasks
                          .where((task) => task.status == 'Devam Ediyor')
                          .toList();
                      final upcomingTasks = tasks
                          .where((task) => task.status == 'Tamamlanacak')
                          .toList();

                      return ListView(
                        children: [
                          _buildTaskSection(
                              context, 'Tamamlanan Görevler', completedTasks,
                              color: Colors.grey[100],
                              headerColor:
                                  const Color.fromARGB(255, 19, 117, 19)),
                          _buildTaskSection(
                              context, 'Devam Eden Görevler', inProgressTasks,
                              color: Colors.grey[100],
                              headerColor:
                                  const Color.fromARGB(255, 21, 77, 114)),
                          _buildTaskSection(
                              context, 'Başlayacak Görevler', upcomingTasks,
                              color: Colors.grey[100],
                              headerColor:
                                  const Color.fromARGB(255, 134, 127, 27)),
                        ],
                      );
                    } else {
                      return Center(child: Text('Henüz görev atanmadı.'));
                    }
                  },
                ),
              ),
              SizedBox(height: 24),
              AppElevatedButton(
                onPressed: () async =>
                    await AppDialogs.showConfirmDialog(context).then(
                        (value) async => (value ?? false)
                            ? await DbEmployeeService()
                                .deleteEmployee(employee.id)
                                .then((value) => Navigator.pop(context, true))
                            : null),
                title: 'Çalışanı Sil',
                icon: Icons.delete,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskSection(BuildContext context, String title, List<Task> tasks,
      {Color? color, Color? headerColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: headerColor,
            ),
          ),
        ),
        SizedBox(height: 8),
        ...tasks.map((task) => Card(
              margin: EdgeInsets.symmetric(vertical: 4),
              color: Colors.grey[100],
              child: ListTile(
                title: Text(
                  task.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Başlama: ${task.startDate}, Bitiş: ${task.endDate}, Süre: ${task.manHour} saat',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            )),
        SizedBox(height: 16),
      ],
    );
  }
}
