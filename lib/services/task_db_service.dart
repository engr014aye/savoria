import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_item.dart';

class TaskDbService {
  static final TaskDbService _instance = TaskDbService._internal();
  factory TaskDbService() => _instance;
  TaskDbService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'savoria_tasks.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            notes TEXT,
            category TEXT NOT NULL,
            priority TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            dueTime TEXT NOT NULL,
            isCompleted INTEGER NOT NULL,
            createdAt TEXT NOT NULL,
            completedAt TEXT
          )
        ''');

        // Seed initial high-quality daily tasks
        await _seedInitialTasks(db);
      },
    );
  }

  static Future<void> _seedInitialTasks(Database db) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final initialTasks = [
      TaskItem(
        title: "Executive Strategy & Q4 Roadmap Review",
        notes: "Align quarterly milestones with VIP Food Company executive board.",
        category: "Work & Executive",
        priority: "Urgent",
        dueDate: today,
        dueTime: "09:30 AM",
        isCompleted: true,
        createdAt: "$today 08:00",
        completedAt: "$today 09:15",
      ),
      TaskItem(
        title: "Curate Artisanal Provisions & Daily Savor Menu",
        notes: "Review seasonal harvests, culinary pairings, and organic inventories.",
        category: "Today",
        priority: "High",
        dueDate: today,
        dueTime: "11:00 AM",
        isCompleted: false,
        createdAt: "$today 08:30",
      ),
      TaskItem(
        title: "Review Sommelier Reserve Allocations",
        notes: "Inspect cellar temperature curves and Grand Cru vintages.",
        category: "Work & Executive",
        priority: "Medium",
        dueDate: today,
        dueTime: "02:30 PM",
        isCompleted: false,
        createdAt: "$today 09:00",
      ),
      TaskItem(
        title: "Midday Mindfulness & Posture Reset",
        notes: "15-minute ergonomic reset and hydration breathing exercise.",
        category: "Personal & Wellness",
        priority: "Normal",
        dueDate: today,
        dueTime: "03:45 PM",
        isCompleted: true,
        createdAt: "$today 09:30",
        completedAt: "$today 12:45",
      ),
      TaskItem(
        title: "Evening Sensory Tasting & Masterclass Reflection",
        notes: "Log aroma balance, acidity curves, and pairing impressions.",
        category: "Focus & Urgent",
        priority: "High",
        dueDate: today,
        dueTime: "07:30 PM",
        isCompleted: false,
        createdAt: "$today 10:00",
      ),
      TaskItem(
        title: "Plan Next Week's Deep Work Sprint",
        notes: "Block uninterrupted focus slots for creative planning.",
        category: "Personal & Wellness",
        priority: "Medium",
        dueDate: today,
        dueTime: "09:00 PM",
        isCompleted: false,
        createdAt: "$today 10:15",
      ),
    ];

    for (final task in initialTasks) {
      await db.insert('tasks', task.toMap());
    }
  }

  Future<List<TaskItem>> getTasks({String? category, bool? isCompleted}) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (category != null && category != 'All') {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }
    if (isCompleted != null) {
      whereClauses.add('isCompleted = ?');
      whereArgs.add(isCompleted ? 1 : 0);
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final results = await db.query(
      'tasks',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'isCompleted ASC, id DESC',
    );
    return results.map((e) => TaskItem.fromMap(e)).toList();
  }

  Future<int> insertTask(TaskItem task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(TaskItem task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> toggleTaskCompletion(int id, bool currentStatus) async {
    final db = await database;
    final newStatus = !currentStatus;
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    await db.update(
      'tasks',
      {
        'isCompleted': newStatus ? 1 : 0,
        'completedAt': newStatus ? now : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
