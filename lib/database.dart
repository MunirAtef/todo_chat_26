import 'package:sqflite/sqflite.dart' show Database, getDatabasesPath, openDatabase;
import 'chat_room.dart';


class Databases {
  static Database? _db;

  Future<Database?> get db async {
    _db ??= await buildDatabase();
    return _db;
  }

  buildDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = "$databasePath/appDb.db";
    var myDatabase = await openDatabase(path, onCreate: _onCreate, version: 1);
    return myDatabase;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE connections (
        id INTEGER PRIMARY KEY,
        name TEXT,
        address TEXT,
        image TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        isMe INTEGER,
        type INTEGER,
        content TEXT,
        time TEXT,
        replayTo TEXT,
        dest TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE memories (
        id TEXT PRIMARY KEY,
        description TEXT,
        image TEXT,
        postedTime TEXT,
        memoryTime TEXT,
        
      )
    ''');
  }


  /// connections table functions
  addConnection(String name, String address, String image) async {
    String sql = "INSERT INTO 'connections' ('name', 'address', 'image') VALUES ('$name', '$address', '$image')";
    Database? myDatabase = await db;
    int response = await myDatabase!.rawInsert(sql);  //response = 0 if it failed
    return response;
  }

  /// id, type, content, time, replayTo, dest
  getConnections() async {
    String sql = "SELECT * FROM 'connections'";
    Database? myDatabase = await db;
    List<Map> response = await myDatabase!.rawQuery(sql);
    return response;
  }


  /// messages table functions
  addMessage(Message msg) async {
    int isMe = msg.isMe? 1:0;
    String sql = """
      INSERT INTO 'messages' (id, isMe, type, content, time, replayTo, dest) VALUES 
      ('${msg.id}', $isMe, ${msg.type}, '${msg.content}', '${msg.time}', '${msg.replayTo}', '${msg.dest}')
    """;

    Database? myDatabase = await db;
    int response = await myDatabase!.rawInsert(sql);  //response = 0 if it failed
    return response;
  }

  getMessages(String dest) async {
    String sql = "SELECT * FROM 'messages' WHERE dest = '$dest'";
    Database? myDatabase = await db;
    List<Map> response = await myDatabase!.rawQuery(sql);
    return response;
  }

  getMessageById(String id) async {
    String sql = "SELECT * FROM 'messages' WHERE id = '$id'";
    Database? myDatabase = await db;
    List<Map> response = await myDatabase!.rawQuery(sql);
    return response[0];
  }


  // readData(String condition) async {
  //   String sql = "SELECT * FROM 'client' WHERE $condition";
  //   Database? myDatabase = await db;
  //   List<Map> response = await myDatabase!.rawQuery(sql);
  //   return response;
  // }
  //
  // insertData(String name, String phone, String image) async {
  //   String sql = "INSERT INTO 'client' ('name', 'phone', 'image') VALUES ('$name', '$phone', '$image')";
  //   Database? myDatabase = await db;
  //   int response = await myDatabase!.rawInsert(sql);  //response = 0 if it failed
  //   return response;
  // }
  //
  // updateData(String condition, String data) async {
  //   String sql = "UPDATE 'client' SET $data WHERE $condition";
  //   Database? myDatabase = await db;
  //   int response = await myDatabase!.rawUpdate(sql);
  //   return response;
  // }
  //
  // deleteData(String condition) async {
  //   String sql = "DELETE FROM 'client' WHERE $condition";
  //   Database? myDatabase = await db;
  //   int response = await myDatabase!.rawDelete(sql);
  //   return response;
  // }
}


