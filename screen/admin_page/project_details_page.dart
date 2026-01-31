import 'package:flutter/material.dart';
import 'package:proje_takip/models/project.dart';
import 'package:proje_takip/models/task.dart';
import 'package:proje_takip/screen/admin_page/add_task_page.dart';
import 'package:proje_takip/screen/admin_page/task_details.dart';
import 'package:proje_takip/services/db_employee_service.dart';
import 'package:proje_takip/services/db_project_service.dart';
import 'package:proje_takip/services/db_task_service.dart';
import 'package:proje_takip/utils/app_dialogs.dart';
import 'package:proje_takip/utils/app_elevated_button.dart';
import 'package:proje_takip/utils/custom_container.dart';
import 'package:proje_takip/utils/responsive.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;

  const ProjectDetailsPage({required this.project, super.key});

  @override
  ProjectDetailsPageState createState() => ProjectDetailsPageState();
}

class ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late Future<int?> delayDaysFuture;

  @override
  void initState() {
    super.initState();
    delayDaysFuture = DbTaskService().calculateProjectDelay(widget.project.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.project.name} Detayları'),
      ),
      body: Padding(
        padding: Responsive.pagePadding(context),
        child: CustomContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.project.completionDate != null
                  ? Text(
                      'Bu Proje Sonlandı. Bitiş Tarihi: ${widget.project.completionDate}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800]))
                  : Text('Proje Devam Ediyor',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Proje Başlangıç Tarihi: ${widget.project.startDate}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Proje Bitiş Tarihi: ${widget.project.targetEndDate}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              ProjectStatusWidget(endDate: widget.project.targetEndDate),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Text(
                'Görevler',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder<List<Task>>(
                  future:
                      DbTaskService().getTasksByProjectId(widget.project.id),
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
                                'Bu proje için henüz görev tanımlanmamış.'));
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return ListTile(
                                  onTap:
                                      !(widget.project.completionDate == null)
                                          ? null
                                          : () => push(
                                              context,
                                              TaskDetailsPage(
                                                  task: task,
                                                  project: widget.project)),
                                  title: Text(task.name),
                                  subtitle: Text(
                                      'Başlama: ${task.startDate}, Bitiş: ${task.endDate}, Adam Saat: ${task.manHour}'),
                                  trailing: _buildTaskStatusBadge(task.status),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 24),
                          widget.project.completionDate == null
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: AppElevatedButton(
                                      onPressed: () async {
                                        await AppDialogs.showConfirmDialog(
                                                context,
                                                content:
                                                    'Tüm görevler tamamlandı işaretlenecek ve proje sonlandırılacak. Emin misiniz?')
                                            .then(
                                          (value) async {
                                            if (value ?? false) {
                                              if (snapshot.data!.isNotEmpty) {
                                                for (var task
                                                    in snapshot.data!) {
                                                  await DbTaskService()
                                                      .completeTask(task.id);
                                                  await DbEmployeeService()
                                                      .updateEmployee(
                                                          id: task.employeeId!,
                                                          activeTaskId: null,
                                                          activeProjectId:
                                                              null);
                                                }
                                              }
                                              await DbProjectService()
                                                  .compleateProject(
                                                      widget.project.id);
                                            }
                                            setState(() {});
                                          },
                                        );
                                      },
                                      title: 'Projeyi Sonlandır'),
                                )
                              : SizedBox(),
                        ],
                      );
                    } else {
                      return Center(child: Text('Görev bulunmuyor.'));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.project.completionDate == null
          ? FloatingActionButton(
              onPressed: () {
                push(context, AddTaskPage(projectId: widget.project.id));
              },
              backgroundColor: Colors.indigo[700],
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Future<dynamic> push(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then(
      (value) => setState(() {}),
    );
  }

  Widget _buildTaskStatusBadge(String status) {
    Color badgeColor;

    switch (status) {
      case 'Tamamlanacak':
        badgeColor = Colors.orange;
        break;
      case 'Devam Ediyor':
        badgeColor = Colors.indigo;
        break;
      case 'Tamamlandı':
        badgeColor = Colors.green;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class ProjectStatusWidget extends StatelessWidget {
  final String endDate;

  const ProjectStatusWidget({super.key, required this.endDate});

  @override
  Widget build(BuildContext context) {
    final projectEndDate = DateTime.parse(endDate);
    final currentDate = DateTime.now();
    final difference = currentDate.difference(projectEndDate);

    if (projectEndDate.isBefore(currentDate)) {
      // Proje geçmiş tarihe sahipse
      if (difference.inDays > 0) {
        // Geç kalınan gün
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proje Gecikti: ',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(width: 4),
            Text(
              'Geç kalınan gün: ${difference.inDays} gün',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      } else if (difference.inHours > 0) {
        // Geç kalınan saat
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proje Gecikti',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Geç kalınan süre: ${difference.inHours} saat ${difference.inMinutes % 60} dakika',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      } else {
        // Geç kalınan dakika
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proje Gecikti',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Geç kalınan süre: ${difference.inMinutes} dakika',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }
    } else {
      return SizedBox.shrink(); // Eğer geç kalmadıysa boş bir widget döner
    }
  }
}
