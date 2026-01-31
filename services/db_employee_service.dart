import 'package:proje_takip/models/employee.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class DbEmployeeService {
  final DatabaseHelper instance = DatabaseHelper.instance;

  Future<bool> authenticateEmployee(String username, String password) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      'employees',
      where: 'name = ? AND password = ?',
      whereArgs: [username, password],
    );

    return result.isNotEmpty;
  }

  Future<Employee?> getEmployee(int id) async {
    final db = await instance.database;

    // Veritabanından employee kaydını çek
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Tek bir kayıta karşılık geliyorsa, Employee modeline dönüştür
    if (maps.isNotEmpty) {
      return Employee.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> addEmployee(String name, String password) async {
    final db = await instance.database;

    await db.insert(
      'employees',
      {
        'name': name,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateEmployee(
      {required int id,
      String? name,
      String? password,
      int? activeTaskId,
      int? activeProjectId}) async {
    final db = await instance.database;

    Map<String, dynamic> updateValues = {};

    if (name != null) updateValues['name'] = name;
    if (password != null) updateValues['password'] = password;
    if (activeTaskId != null) updateValues['activeTaskId'] = activeTaskId;
    if (activeProjectId != null) {
      updateValues['activeProjectId'] = activeProjectId;
    }

    if (updateValues.isNotEmpty) {
      await db.update(
        'employees',
        updateValues,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> deleteEmployee(int id) async {
    final db = await instance.database;

    await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await instance.database;

    // Veritabanından tüm çalışanları çek
    final List<Map<String, dynamic>> maps = await db.query('employees');

    // Maps listesindeki her bir satırı Employee modeline dönüştür
    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }
}
