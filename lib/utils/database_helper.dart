// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'package:todo_bloc/model/todo.dart';
//
// class DatabaseHelper {
//   DatabaseHelper._internal();
//
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//
//   factory DatabaseHelper() => _instance;
//   static Database? _database;
//
//   Future<Database> get database async {
//     _database ??= await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, 'todo_database.db');
//     return await openDatabase(path, version: 1, onCreate: _onCreate);
//   }
//
//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute("""
//       CREATE TABLE todos(
//         id TEXT PRIMARY KEY,
//         title TEXT,
//         isChecked INTEGER,
//         priority TEXT,
//         taskDate INTEGER,
//         taskTime INTEGER,
//         description TEXT,
//         userLocation REAL
//       )
//     """);
//   }
//
//   Future<int> insertTodo(Todo todo) async {
//     Database db = await database;
//     return await db.insert('todos', todo.toMap());
//   }
//
//   Future<List<Todo>> getTodos() async {
//     Database db = await database;
//     List<Map<String, dynamic>> maps = await db.query('todos');
//     return List.generate(maps.length, (i) {
//       return Todo.fromMap(maps[i]);
//     });
//   }
//
//   Future<int> updateTodo(Todo todo) async {
//     Database db = await database;
//     return await db.update(
//       'todos',
//       todo.toMap(),
//       where: 'id=?',
//       whereArgs: [todo.id],
//     );
//   }
//
//   Future<int> deleteTodo(String id) async {
//     Database db = await database;
//     return await db.delete('todos', where: 'id=?', whereArgs: [id]);
//   }
//
//   Future<void> close() async {
//     Database db = await database;
//     db.close();
//   }
// }
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:todo_bloc/model/todo.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'todo_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE todos(
        id TEXT PRIMARY KEY,
        title TEXT,
        isChecked INTEGER,
        priority TEXT,
        taskDate INTEGER,
        taskTime INTEGER,
        description TEXT,
        userLocation REAL
      )
    """);
  }

  Future<int> insertTodo(Todo todo) async {
    Database db = await database;
    return await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> getTodos() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<int> updateTodo(Todo todo) async {
    Database db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id=?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(String id) async {
    Database db = await database;
    return await db.delete('todos', where: 'id=?', whereArgs: [id]);
  }

  Future<List<Todo>> getTodosDueInNext30Minutes() async {
    Database db = await database;
    DateTime now = DateTime.now();
    DateTime thirtyMinutesFromNow = now.add(Duration(minutes: 30));
    int nowMillis = now.millisecondsSinceEpoch;
    int thirtyMinutesMillis = thirtyMinutesFromNow.millisecondsSinceEpoch;

    List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'taskTime >= ? AND taskTime <= ?',
      whereArgs: [nowMillis, thirtyMinutesMillis],
    );

    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<void> close() async {
    Database db = await database;
    db.close();
  }
}
