class Task {
  int id;
  int projectId;
  int? employeeId;
  String name;
  double manHour;
  String startDate;
  String endDate;
  String status;

  Task({
    required this.id,
    required this.projectId,
    required this.employeeId,
    required this.name,
    required this.manHour,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  // SQL'den alınan verileri model objesine dönüştürmek için bir constructor
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      projectId: map['projectId'],
      employeeId: map['employeeId'],
      name: map['name'],
      manHour: map['manHour'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      status: map['status'],
    );
  }

  // Model objesini SQL'e yazmak için bir map fonksiyonu
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'employeeId': employeeId,
      'name': name,
      'manHour': manHour,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
    };
  }
}

enum TaskStatus { tamamlanacak, devamEdiyor, tamamlandi }

String taskStatusEnumToString(TaskStatus task) {
  switch (task) {
    case TaskStatus.devamEdiyor:
      return 'Devam Ediyor';
    case TaskStatus.tamamlanacak:
      return 'Tamamlanacak';
    case TaskStatus.tamamlandi:
      return 'Tamamlandı';
  }
}
