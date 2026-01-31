import 'package:flutter/material.dart';
import 'package:proje_takip/models/employee.dart';
import 'package:proje_takip/models/project.dart';
import 'package:proje_takip/models/task.dart';
import 'package:proje_takip/services/db_employee_service.dart';
import 'package:proje_takip/services/db_task_service.dart';
import 'package:proje_takip/utils/app_dialogs.dart';
import 'package:proje_takip/utils/custom_container.dart';
import 'package:proje_takip/utils/responsive.dart';

class TaskDetailsPage extends StatefulWidget {
  final Task task;
  final Project project;

  const TaskDetailsPage({super.key, required this.task, required this.project});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late int? selectedEmployeeId;

  @override
  void initState() {
    selectedEmployeeId = widget.task.employeeId;
    super.initState();
  }

  String getTaskStatus() {
    if (widget.task.status == 'Tamamlandı') {
      return 'Tamamlandı';
    } else if (selectedEmployeeId == null) {
      return 'Tamamlanacak';
    } else {
      return 'Devam Ediyor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Görev Detayları: ${widget.task.name}'),
      ),
      body: Padding(
        padding: Responsive.pagePadding(context),
        child: CustomContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskInfoRow('Proje:', widget.project.name),
              _buildTaskInfoRow('Durum:', getTaskStatus()),
              _buildTaskInfoRow('Başlangıç Tarihi:', widget.task.startDate),
              _buildTaskInfoRow('Bitiş Tarihi:', widget.task.endDate),
              _buildTaskInfoRow('Adam Gün:', widget.task.manHour.toString()),
              const SizedBox(height: 16.0),
              const Text(
                'Çalışan Atama veya Değiştirme',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              FutureBuilder<List<Employee>>(
                future: DbEmployeeService().getAllEmployees(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Çalışanlar yüklenemedi.');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Hiç çalışan bulunamadı.');
                  }

                  final employees = snapshot.data!;
                  return DropdownButtonFormField<int?>(
                    focusColor: Colors.white70,
                    value: selectedEmployeeId,
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Seçim Yok'),
                      ),
                      ...employees
                          .map<DropdownMenuItem<int>>((Employee employee) {
                        return DropdownMenuItem<int>(
                          value: employee.id,
                          child: Text(employee.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedEmployeeId = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Çalışan Seçin',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (widget.task.startDate.isEmpty ||
                          widget.task.endDate.isEmpty) {
                        AppDialogs.showErrorDialog(context,
                            'Başlangıç ve bitiş tarihleri boş olamaz.');
                        return;
                      }

                      final updatedStatus = getTaskStatus();

                      await DbTaskService().updateTask(
                        id: widget.task.id,
                        employeeId: selectedEmployeeId,
                        status: updatedStatus,
                      );
                      await DbEmployeeService().updateEmployee(
                          id: widget.task.employeeId!, activeTaskId: null);

                      if (selectedEmployeeId != null) {
                        await DbEmployeeService().updateEmployee(
                            id: selectedEmployeeId!,
                            activeTaskId: widget.task.id);
                      }
                      Navigator.pop(context);
                      AppDialogs.showSuccedDialog(context, title: 'Kaydedildi');
                    },
                    child: const Text('Kaydet'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      AppDialogs.showConfirmDialog(context).then((value) async {
                        if (value ?? false) {
                          await DbTaskService().deleteTask(widget.task.id);
                          Navigator.pop(context);
                          AppDialogs.showSuccedDialog(context);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Görevi Sil'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8.0),
          Text(value),
        ],
      ),
    );
  }
}
