import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('project_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE admins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        password TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        activeTaskId INTEGER,
        activeProjectId INTEGER,
        FOREIGN KEY (activeTaskId) REFERENCES tasks(id),
        FOREIGN KEY (activeProjectId) REFERENCES projects(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        startDate TEXT NOT NULL,
        targetEndDate TEXT NOT NULL,
        completionDate TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        manHour REAL NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        status TEXT CHECK(status IN ('Tamamlanacak', 'Devam Ediyor', 'Tamamlandı')) NOT NULL,
        projectId INTEGER NOT NULL,
        employeeId INTEGER,
        FOREIGN KEY (projectId) REFERENCES projects(id),
        FOREIGN KEY (employeeId) REFERENCES employees(id)
      );
    ''');
  }
}
