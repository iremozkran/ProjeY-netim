import 'package:flutter/material.dart';
import 'package:proje_takip/models/admin.dart';
import 'package:proje_takip/models/employee.dart';
import 'package:proje_takip/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DbAdminService {
  final DatabaseHelper instance = DatabaseHelper.instance;
  Future authenticateUser(String name, String password) async {
    try {
      final db = await instance.database; // Veritabanını alın

      // Admin tablosunda arama yap
      final List<Map<String, dynamic>> adminResult = await db.query(
        'admins',
        where: 'name = ? AND password = ?',
        whereArgs: [name, password],
      );

      if (adminResult.isNotEmpty) {
        return Admin.fromMap(
            adminResult.first); // Eğer admin bilgileri doğruysa "admin" döndür
      }

      // Employee tablosunda arama yap
      final List<Map<String, dynamic>> employeeResult = await db.query(
        'employees',
        where: 'name = ? AND password = ?',
        whereArgs: [name, password],
      );

      if (employeeResult.isNotEmpty) {
        return Employee.fromMap(employeeResult
            .first); // Eğer employee bilgileri doğruysa "employee" döndür
      }

      return null; // Bilgiler eşleşmiyorsa null döndür
    } catch (e) {
      // Hata mesajını logla ve null döndür
      debugPrint('Error in authenticateUser: $e');
      return null;
    }
  }

  Future<Admin?> getAdmin(int id) async {
    final db = await instance.database;

    // Veritabanından admin kaydını çek
    final List<Map<String, dynamic>> maps = await db.query(
      'admins',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Tek bir kayıta karşılık geliyorsa, Admin modeline dönüştür
    if (maps.isNotEmpty) {
      return Admin.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> addAdmin(String name, String password) async {
    final db = await instance.database;

    // Önce belirtilen adı taşıyan yöneticiyi sorgula
    final List<Map<String, dynamic>> existingAdmins = await db.query(
      'admins',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (existingAdmins.isEmpty) {
      try {
        await db.insert(
          'admins',
          {'name': name, 'password': password},
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
      } catch (_) {}
    } else {}
  }

  Future<void> updateAdmin(int id, String name, String password) async {
    final db = await instance.database;

    await db.update(
      'admins',
      {'name': name, 'password': password},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAdmin(int id) async {
    final db = await instance.database;

    await db.delete(
      'admins',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllAdmins() async {
    final db = await instance.database;

    try {
      await db.execute('DELETE FROM admins');
    } catch (_) {}
  }

  Future<List<Admin>> getAllAdmins() async {
    final db = await instance.database;

    // Veritabanından tüm Adminleri çek
    final List<Map<String, dynamic>> maps = await db.query('admins');

    // Maps listesindeki her bir satırı Admin modeline dönüştür
    return List.generate(maps.length, (i) {
      return Admin.fromMap(maps[i]);
    });
  }
}
