import 'package:mongo_dart/mongo_dart.dart';

class MongoClient {
  MongoClient(this._uri);
  final String _uri;
  Db? _db;

  Future<Db> get db async {
    if (_db != null && _db!.isConnected) {
      return _db!;
    }
    _db = await Db.create(_uri);
    await _db!.open();
    return _db!;
  }

  Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
    }
  }
}
