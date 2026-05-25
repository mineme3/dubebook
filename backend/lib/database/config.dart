import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'mongo_client.dart';

class Config {
  static final env = DotEnv(includePlatformEnvironment: true)
    ..load(['.env']);

  static final String mongoUri = Platform.environment['MONGO_URI'] ?? 
      env['MONGO_URI'] ?? 
      'mongodb://localhost:27017/creditdb';
  static final String jwtSecret = env['JWT_SECRET'] ?? 'super_secret_dubebook_jwt_key_that_is_at_least_32_characters_long';
  static final int jwtExpiry = int.tryParse(env['JWT_EXPIRY'] ?? '86400') ?? 86400;
  static final String telegramBotToken = env['TELEGRAM_BOT_TOKEN'] ?? '1234567890:ABCDefghIJKLmnop';

  static final MongoClient _client = MongoClient(mongoUri);

  static Future<Db> get db => _client.db;

  static Future<void> close() async {
    await _client.close();
  }
}
