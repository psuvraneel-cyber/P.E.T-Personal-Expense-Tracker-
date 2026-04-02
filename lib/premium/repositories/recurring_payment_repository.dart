import 'package:sqflite/sqflite.dart';
import 'package:pet/data/database/database_helper.dart';
import 'package:pet/premium/models/recurring_payment.dart';

class RecurringPaymentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<RecurringPayment>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('recurring_payments', orderBy: 'nextDueAt ASC');
    return maps.map((m) => RecurringPayment.fromMap(m)).toList();
  }

  Future<void> upsert(RecurringPayment payment) async {
    final db = await _dbHelper.database;
    await db.insert(
      'recurring_payments',
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearAll() async {
    final db = await _dbHelper.database;
    await db.delete('recurring_payments');
  }

  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('recurring_payments', where: 'id = ?', whereArgs: [id]);
  }
}
