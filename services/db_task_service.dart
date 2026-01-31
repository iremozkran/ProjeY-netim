import 'package:proje_takip/models/task.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class DbTaskService {
  final DatabaseHelper instance = DatabaseHelper.instance;

  Future<int?> addTask(int projectId, int? employeeId, String name,
      double manHour, String startDate, String endDate, String status) async {
    final db = await instance.database;
    return await db.insert(
      'tasks',
      {
        'projectId': projectId,
        'employeeId': employeeId,
        'name': name,
        'manHour': manHour,
        'startDate': startDate,
        'endDate': endDate,
        'status': status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Task?> getTask(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int?> calculateProjectDelay(int projectId) async {
    final tasks = await getTasksByProjectId(projectId);
    int delayDays = 0;
    if (tasks.isEmpty) {
      return null;
    }
    for (final task in tasks) {
      if (task.status != 'Tamamlandı' &&
          DateTime.parse(task.endDate).isBefore(DateTime.now())) {
        delayDays +=
            DateTime.now().difference(DateTime.parse(task.endDate)).inDays;
      }
    }
    return delayDays;
  }

  Future<List<Task>> getEmployeeHistoryTask(
    employeeId,
  ) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'tasks',
      where: 'status = ? AND employeeId = ?',
      whereArgs: [taskStatusEnumToString(TaskStatus.tamamlandi), employeeId],
    );
    return result.map((e) => Task.fromMap(e)).toList();
  }

  Future<List<Task>> getTasksByProjectId(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'tasks',
      where: 'projectId = ?',
      whereArgs: [id],
    );
    print(result);
    return result.map((task) => Task.fromMap(task)).toList();
  }

  Future<List<Task>> getTasksByEmployeeId(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'tasks',
      where: 'employeeId = ?',
      whereArgs: [id],
    );
    return result.map((task) => Task.fromMap(task)).toList();
  }

  Future<void> updateTask({
    required int id,
    int? projectId,
    int? employeeId,
    String? name,
    double? manHour,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    final db = await instance.database;
    Map<String, dynamic> updateValues = {};
    if (projectId != null) updateValues['projectId'] = projectId;
    if (employeeId != null) updateValues['employeeId'] = employeeId;
    if (name != null) updateValues['name'] = name;
    if (manHour != null) updateValues['manHour'] = manHour;
    if (startDate != null) updateValues['startDate'] = startDate;
    if (endDate != null) updateValues['endDate'] = endDate;
    if (status != null) updateValues['status'] = status;
    if (updateValues.isNotEmpty) {
      await db.update(
        'tasks',
        updateValues,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> updateTaskModel(Task task) async {
    final db = await instance.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> completeTask(int id) async {
    await updateTaskStatus(
        id: id, status: taskStatusEnumToString(TaskStatus.tamamlandi));
  }

  Future<void> updateTaskStatus(
      {required int id, required String status}) async {
    final db = await instance.database;

    await db.update(
      'tasks',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await instance.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        projectId: maps[i]['projectId'],
        employeeId: maps[i]['employeeId'],
        name: maps[i]['name'],
        manHour: maps[i]['manHour'].toDouble(),
        startDate: maps[i]['startDate'],
        endDate: maps[i]['endDate'],
        status: maps[i]['status'],
      );
    });
  }
}
