import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'contact.dart';

class DatabaseHelper {
  static const _databaseName = "MyContacts.db";
  static const _databaseVersion = 1;

  static const table = 'contacts';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnPhone = 'phone';
  static const columnLastContacted = 'lastContacted';
  static const columnNotes = 'notes';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnPhone TEXT NOT NULL,
            $columnLastContacted TEXT NOT NULL,
            $columnNotes TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Contact contact) async {
    Database db = await instance.database;
    return await db.insert(table, contact.toMap());
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Contact>> getContacts() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Contact contact) async {
    Database db = await instance.database;
    int id = contact.id!;
    return await db.update(table, contact.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
