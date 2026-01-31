import 'package:intl/intl.dart';
import 'package:proje_takip/helper/app_constants.dart';
import 'package:proje_takip/models/project.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class DbProjectService {
  final DatabaseHelper instance = DatabaseHelper.instance;

  Future<int> addProject(
      String name, String startDate, String targetEndDate) async {
    final db = await instance.database;

    return await db.insert(
      'projects',
      {'name': name, 'startDate': startDate, 'targetEndDate': targetEndDate},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Project?> getProject(int id) async {
    final db = await instance.database;

    // Veritabanından proje kaydını çek
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Tek bir kayıta karşılık geliyorsa, Project modeline dönüştür
    if (maps.isNotEmpty) {
      return Project.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Project?> getProjectByTaskId(int id) async {
    final db = await instance.database;

    // Veritabanından proje kaydını çek
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'task = ?',
      whereArgs: [id],
    );

    // Tek bir kayıta karşılık geliyorsa, Project modeline dönüştür
    if (maps.isNotEmpty) {
      return Project.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> updateProject(int id, String name, String startDate,
      String targetEndDate, String? completionDate) async {
    final db = await instance.database;

    // Güncellenecek veri oluşturuluyor
    Map<String, dynamic> updateValues = {
      'name': name,
      'startDate': startDate,
      'targetEndDate': targetEndDate,
    };

    if (completionDate != null) {
      updateValues['completionDate'] = completionDate;
    }

    if (updateValues.isNotEmpty) {
      await db.update(
        'projects',
        updateValues,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> compleateProject(int id) async {
    final db = await instance.database;

    await db.update(
      'projects',
      {'completionDate': DateFormat(appDateTimeFormat).format(DateTime.now())},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteProject(int id) async {
    final db = await instance.database;

    await db.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Project>> getAllProjects() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query('projects');

    // Maps listesindeki her bir satırı Project modeline dönüştür
    return List.generate(maps.length, (i) {
      return Project.fromMap(maps[i]);
    });
  }
}
