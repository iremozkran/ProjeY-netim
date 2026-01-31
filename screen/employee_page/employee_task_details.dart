import 'package:flutter/material.dart';
import 'package:proje_takip/models/project.dart';
import 'package:proje_takip/models/task.dart';
import 'package:proje_takip/services/db_project_service.dart';
import 'package:proje_takip/services/db_task_service.dart';
import 'package:proje_takip/utils/app_dialogs.dart';
import 'package:proje_takip/utils/app_elevated_button.dart';
import 'package:proje_takip/utils/custom_container.dart';
import 'package:proje_takip/utils/responsive.dart';

class EmployeeTaskDetailsPage extends StatefulWidget {
  final Task task;
  final bool complete;

  const EmployeeTaskDetailsPage(
      {required this.task, super.key, required this.complete});

  @override
  State<EmployeeTaskDetailsPage> createState() =>
      _EmployeeTaskDetailsPageState();
}

class _EmployeeTaskDetailsPageState extends State<EmployeeTaskDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Görev Detayı: ${widget.task.name}'),
        backgroundColor: Colors.indigo[600],
      ),
      body: Padding(
        padding: Responsive.pagePadding(context),
        child: CustomContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Proje Detayları',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
                ),
              ),
              SizedBox(height: 12),
              FutureBuilder<Project?>(
                future: DbProjectService().getProject(widget.task.projectId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Hata: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return Column(
                      children: [
                        _buildDetailRow('Proje Adı', snapshot.data!.name),
                        _buildDetailRow(
                            'Proje Durumu',
                            snapshot.data!.completionDate == null
                                ? 'Devam Ediyor'
                                : 'Proje Sonlandı'),
                        _buildDetailRow(
                            'Proje Başlangıç Tarihi', snapshot.data!.startDate),
                        _buildDetailRow('Proje Hedef Bitiş Tarihi',
                            snapshot.data!.targetEndDate),
                      ],
                    );
                  } else {
                    return Center(
                        child: Text(
                            'Bu görevin bağlı olduğu bir proje bulunamadı.'));
                  }
                },
              ),
              SizedBox(height: 32),
              Text(
                'Görev Detayları',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
                ),
              ),
              SizedBox(height: 12),
              _buildDetailRow('Görev Adı', widget.task.name),
              _buildDetailRow('Başlama Tarihi', widget.task.startDate),
              _buildDetailRow('Bitiş Tarihi', widget.task.endDate),
              _buildDetailRow('Süre', '${widget.task.manHour} saat'),
              _buildDetailRow('Durum', widget.task.status),
              Spacer(),
              widget.complete
                  ? SizedBox()
                  : AppElevatedButton(
                      onPressed: () => AppDialogs.showConfirmDialog(context,
                              content:
                                  'Görevi tamamladığınızı onaylıyor musunuz?')
                          .then((value) async => (value ?? false)
                              ? await DbTaskService()
                                  .updateTaskStatus(
                                      id: widget.task.id,
                                      status: taskStatusEnumToString(
                                          TaskStatus.tamamlandi))
                                  .then(
                                    (value) => Navigator.pop(context, true),
                                  )
                              : null),
                      title: 'Tamamlandı işaretle')
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
