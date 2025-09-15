import 'package:my_app/model/project.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:my_app/model/note.dart';
import 'package:my_app/model/transaction.dart' as tx;
import 'package:my_app/model/task.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  // Initialize and open the database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create the tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        projectId TEXT PRIMARY KEY,
        projectName TEXT,
        status INTEGER
      )
    ''');

    await db.execute('''
      INSERT INTO projects (projectId, projectName, status) VALUES ('default', 'No Project', 0)
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        taskId TEXT PRIMARY KEY,
        taskName TEXT,
        startTime TEXT,
        endTime TEXT,
        reminder TEXT,
        status INTEGER,
        projectId TEXT,
        FOREIGN KEY (projectId) REFERENCES project(projectId) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        transactionId TEXT PRIMARY KEY,
        transactionTime TEXT,
        transactionReason TEXT,
        amount INTEGER,
        projectId TEXT,
        FOREIGN KEY (projectId) REFERENCES project(projectId) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes(
        noteId TEXT PRIMARY KEY,
        noteTime TEXT,
        noteTitle TEXT,
        note TEXT,
        description TEXT,
        projectId TEXT,
        FOREIGN KEY (projectId) REFERENCES project(projectId) ON DELETE SET NULL
      )
    ''');
  }

  //--------------------Project CRUD ------------------------
  Future<int> insertProject(Project project) async {
    final db = await database;
    return await db.insert('projects', project.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Project>> getAllProjects() async {
    final db = await database;
    final maps = await db.query('projects');
    return List.generate(maps.length, (i) => Project.fromMap(maps[i]));
  }

  Future<Project> getProject(String projectId) async {
    final db = await database;
    final maps = await db
        .query('projects', where: 'projectId = ?', whereArgs: [projectId]);
    return List.generate(maps.length, (p) => Project.fromMap(maps[0]))[0];
  }

  Future<int> updateProject(Project project) async {
    final db = await database;
    return await db.update('projects', project.toMap(),
        where: 'projectId = ?', whereArgs: [project.projectId]);
  }

  Future<int> deleteProject(String projectId) async {
    final db = await database;
    return await db
        .delete('projects', where: 'projectId = ?', whereArgs: [projectId]);
  }

  // ---------------------- Task CRUD ----------------------

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksOfTheDay(DateTime date) async {
    final db = await database;
    final maps = await db.query('tasks');
    return maps
        .map((map) => Task.fromMap(map))
        .where((task) =>
            task.startTime.year == date.year &&
            task.startTime.month == date.month &&
            task.startTime.day == date.day)
        .toList();
  }

    Future<List<Task>> getTasksOfProject(String projectId) async {
    final db = await database;
    final maps = await db.query('tasks');
    return maps
        .map((map) => Task.fromMap(map))
        .where((task) =>
            task.projectId == projectId)
        .toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update('tasks', task.toMap(),
        where: 'taskId = ?', whereArgs: [task.taskId]);
  }

  Future<int> deleteTask(String taskId) async {
    final db = await database;
    return await db.delete('tasks', where: 'taskId = ?', whereArgs: [taskId]);
  }

  // ------------------- Transaction CRUD -------------------

  Future<int> insertTransaction(tx.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<tx.Transaction>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions');
    return List.generate(maps.length, (i) => tx.Transaction.fromMap(maps[i]));
  }

  Future<List<tx.Transaction>> getTransactionsOfTheDay(DateTime date) async {
    final db = await database;
    final maps = await db.query('transactions');
    return maps
        .map((transaction) => tx.Transaction.fromMap(transaction))
        .where((transaction) =>
            transaction.transactionTime.year == date.year &&
            transaction.transactionTime.month == date.month &&
            transaction.transactionTime.day == date.day)
        .toList();
  }

   /* Future<List<tx.Transaction>> getTransactionsOfProject(String projectId) async {
    final db = await database;
    final maps = await db.query('transactions');
    return maps
        .map((transaction) => tx.Transaction.fromMap(transaction))
        .where((transaction) =>
            transaction.projectId ==  projectId)
        .toList();
  }*/

  Future<int> getMoneyPointOfTheDay(DateTime date) async {
    final db = await database;
    final maps = await db.query('transactions');
    var transactions = maps
        .map((transaction) => tx.Transaction.fromMap(transaction))
        .where((transaction) =>
            transaction.transactionTime.year == date.year &&
            transaction.transactionTime.month == date.month &&
            transaction.transactionTime.day == date.day)
        .toList();
    int point = 0;
    for (var depense in transactions) {
      point += depense.amount;
    }
    return point;
  }

  Future<int> getMoneyPoint() async {
    final db = await database;
    final maps = await db.query('transactions');
    var transactions =
        maps.map((transaction) => tx.Transaction.fromMap(transaction)).toList();
    int point = 0;
    for (var depense in transactions) {
      point += depense.amount;
    }
    return point;
  }

  Future<int> updateTransaction(tx.Transaction transaction) async {
    final db = await database;
    return await db.update('transactions', transaction.toMap(),
        where: 'transactionId = ?', whereArgs: [transaction.transactionId]);
  }

  Future<int> deleteTransaction(String transactionId) async {
    final db = await database;
    return await db.delete('transactions',
        where: 'transactionId = ?', whereArgs: [transactionId]);
  }

  // ---------------------- Note CRUD -----------------------

  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<List<Note>> getNotesOfTheDay(DateTime date) async {
    final db = await database;
    final maps = await db.query('notes');
    return maps
        .map((note) => Note.fromMap(note))
        .where((note) =>
            note.noteTime.year == date.year &&
            note.noteTime.month == date.month &&
            note.noteTime.day == date.day)
        .toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update('notes', note.toMap(),
        where: 'noteId = ?', whereArgs: [note.noteId]);
  }

  Future<int> deleteNote(String noteId) async {
    final db = await database;
    return await db.delete('notes', where: 'noteId = ?', whereArgs: [noteId]);
  }

  // Optional: clear all tables (for testing or resets)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('tasks');
    await db.delete('transactions');
    await db.delete('notes');
  }
}
