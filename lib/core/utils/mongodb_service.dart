import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MongoDbService {
  MongoDbService._internal();
  static final MongoDbService _instance = MongoDbService._internal();
  factory MongoDbService() => _instance;

  late Db _db;
  late DbCollection _contacts;

  DbCollection get contacts => _contacts;

  Future<void> connect() async {
    final uri = dotenv.env['MONGO_URI'];
    if (uri == null || uri.isEmpty) {
      throw Exception('MONGO_URI not found in .env file');
    }
    _db = await Db.create(uri);
    await _db.open();
    _contacts = _db.collection('contacts');
  }

  Future<void> close() async {
    await _db.close();
  }

  bool get isConnected => _db.isConnected;
}
