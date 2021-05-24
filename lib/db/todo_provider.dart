import 'package:todo/db/todo_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TodoProvider {
  late Database db;

  Future open() async {
    db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'todo_database.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, notes TEXT, priority STRING NULLABLE, done BOOLEAN NOT NULL CHECK (done IN (0, 1)))',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future<void> insert(Todo todo) async {
    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query('todos');

    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        notes: maps[i]['notes'],
        priority: maps[i]['priority'],
        done: maps[i]['done'] == 1 ? true : false,
      );
    }).reversed.toList();
  }

  Future<int> update(Todo todo) async {
    return await db
        .update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> delete(int id) async {
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async => db.close();
}
