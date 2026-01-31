import 'package:flutter/material.dart';
import 'package:proje_takip/models/employee.dart';
import 'package:proje_takip/models/task.dart';
import 'package:proje_takip/screen/employee_page/emoployee_histroy_task_page.dart';
import 'package:proje_takip/screen/employee_page/employee_task_details.dart';
import 'package:proje_takip/screen/login_page.dart';
import 'package:proje_takip/services/db_employee_service.dart';
import 'package:proje_takip/services/db_task_service.dart';
import 'package:proje_takip/utils/app_dialogs.dart';
import 'package:proje_takip/utils/app_elevated_button.dart';
import 'package:proje_takip/utils/custom_container.dart';
import 'package:proje_takip/utils/responsive.dart';

class EmployeeHomePage extends StatefulWidget {
  final Employee employee;

  const EmployeeHomePage({required this.employee, super.key});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  Future<List<Task>> _fetchEmployeeTasks() async {
    return await DbTaskService().getTasksByEmployeeId(widget.employee.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoş Geldiniz, ${widget.employee.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              AppDialogs.showConfirmDialog(context,
                      content: 'Çıkış yapmak istediğinizden emin misiniz?')
                  .then(
                (value) => (value ?? false)
                    ? Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()))
                    : null,
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: Responsive.pagePadding(context),
        child: CustomContainer(
          child: Column(
            children: [
              SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Task>>(
                  future: _fetchEmployeeTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Hata: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final tasks = snapshot.data!;
                      if (tasks.isEmpty) {
                        return Center(
                          child: Text(
                            'Henüz atanmış bir göreviniz yok.',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                        );
                      }

                      final inProgressTasks = tasks
                          .where((task) => task.status == 'Devam Ediyor')
                          .toList();
                      final upcomingTasks = tasks
                          .where((task) => task.status == 'Tamamlanacak')
                          .toList();

                      return ListView(
                        children: [
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
                      return Center(
                          child: Text('Henüz atanmış bir göreviniz yok.'));
                    }
                  },
                ),
              ),
              AppElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EmployeeTasksPage(employeeId: widget.employee.id))),
                title: 'Tamamlanan Görevler',
                icon: Icons.history,
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
        if (tasks.isEmpty)
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32),
              child: Text(
                title == 'Başlayacak Görevler'
                    ? 'Başlayacak Görev Yok'
                    : title == 'Devam Eden Görevler'
                        ? 'Devam Eden Göreviniz Yok'
                        : 'Tamamlanmış Göreviniz Yok',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey[500]),
              ),
            ),
          )
        else
          ...tasks.map(
            (task) => Card(
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
                  onTap: () => goDetails(title, context, task),
                  trailing: title == 'Başlayacak Görevler'
                      ? ElevatedButton(
                          onPressed: () {
                            AppDialogs.showConfirmDialog(context,
                                    content:
                                        'Görevi başlatmak istediğinden emin misin?')
                                .then((value) {
                              return (value ?? false)
                                  ? DbTaskService()
                                      .updateTask(
                                          id: task.id,
                                          status: taskStatusEnumToString(
                                              TaskStatus.devamEdiyor))
                                      .then((value) =>
                                          DbEmployeeService().updateEmployee(
                                            id: widget.employee.id,
                                          ))
                                      .then((value) => setState(() {}))
                                  : null;
                            });
                          },
                          child: Text('Başlat'),
                        )
                      : null),
            ),
          ),
        SizedBox(height: 16),
      ],
    );
  }

  void goDetails(String title, BuildContext context, Task task) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EmployeeTaskDetailsPage(
                task: task, complete: title != 'Devam Eden Görevler'))).then(
      (value) => (value ?? false)
          ? setState(() {
              AppDialogs.showSuccedDialog(context,
                  autoClose: true, title: 'Görev tamamlandı');
            })
          : null,
    );
  }
}
