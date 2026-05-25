import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/customer.dart';
import '../models/app_transaction.dart';
import '../models/user.dart';

class DatabaseHelper {
  static const _databaseName = "Dubebook.db";
  static const _databaseVersion = 3; // Incremented for new role tables

  static const tableUser = 'users';
  static const tableCustomer = 'customers';
  static const tableTransaction = 'transactions';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUser (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        security_question TEXT NOT NULL,
        security_answer TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCustomer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        note TEXT,
        deadline TEXT,
        created_at TEXT NOT NULL,
        shopkeeper_id INTEGER,
        remote_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTransaction (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        total REAL NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        transaction_type TEXT NOT NULL DEFAULT 'debt',
        remote_id TEXT,
        customer_remote_id TEXT,
        FOREIGN KEY (customer_id) REFERENCES $tableCustomer (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Re-create to match full fintech-level fields
      await db.execute('DROP TABLE IF EXISTS $tableTransaction');
      await db.execute('DROP TABLE IF EXISTS $tableCustomer');
      await db.execute('DROP TABLE IF EXISTS $tableUser');
      await _onCreate(db, newVersion);
    }
  }

  // --- USER OPERATIONS ---
  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert(tableUser, user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserById(int id) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableUser, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableUser, where: 'email = ?', whereArgs: [email.toLowerCase().trim()]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUserPassword(int id, String newHash) async {
    Database db = await instance.database;
    return await db.update(tableUser, {'password_hash': newHash}, where: 'id = ?', whereArgs: [id]);
  }

  // --- CUSTOMER OPERATIONS ---
  Future<int> insertCustomer(Customer customer) async {
    Database db = await instance.database;
    return await db.insert(tableCustomer, customer.toMap());
  }

  Future<List<Customer>> getCustomers({int? shopkeeperId}) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = shopkeeperId != null
        ? await db.query(tableCustomer, where: 'shopkeeper_id = ?', whereArgs: [shopkeeperId])
        : await db.query(tableCustomer);
    return maps.map((c) => Customer.fromMap(c)).toList();
  }
  
  Future<int> updateCustomer(Customer customer) async {
    Database db = await instance.database;
    return await db.update(tableCustomer, customer.toMap(), where: 'id = ?', whereArgs: [customer.id]);
  }

  Future<int> deleteCustomer(int id) async {
    Database db = await instance.database;
    return await db.delete(tableCustomer, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getUnpaidCustomersWithDebt({int? shopkeeperId}) async {
    Database db = await instance.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];
    if (shopkeeperId != null) {
      whereClause = 'WHERE c.shopkeeper_id = ?';
      whereArgs.add(shopkeeperId);
    }

    return await db.rawQuery('''
      SELECT c.*, COALESCE(SUM(t.total), 0) as total_debt 
      FROM $tableCustomer c
      LEFT JOIN $tableTransaction t ON c.id = t.customer_id AND t.status = 0 AND t.transaction_type = 'debt'
      $whereClause
      GROUP BY c.id
      ORDER BY total_debt DESC, c.name ASC
    ''', whereArgs);
  }

  // --- TRANSACTION OPERATIONS ---
  Future<int> insertTransaction(AppTransaction transaction) async {
    Database db = await instance.database;
    return await db.insert(tableTransaction, transaction.toMap());
  }

  Future<List<AppTransaction>> getTransactionsForCustomer(int customerId, {int? status}) async {
    Database db = await instance.database;
    String where = 'customer_id = ?';
    List<dynamic> whereArgs = [customerId];
    
    if (status != null) {
      where += ' AND status = ?';
      whereArgs.add(status);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableTransaction,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return maps.map((t) => AppTransaction.fromMap(t)).toList();
  }
  
  Future<List<AppTransaction>> getAllTransactions({int? status, int? shopkeeperId}) async {
    Database db = await instance.database;
    String query = '''
      SELECT t.* FROM $tableTransaction t
      INNER JOIN $tableCustomer c ON t.customer_id = c.id
    ''';
    List<dynamic> args = [];
    
    if (shopkeeperId != null) {
      query += ' WHERE c.shopkeeper_id = ?';
      args.add(shopkeeperId);
      if (status != null) {
        query += ' AND t.status = ?';
        args.add(status);
      }
    } else if (status != null) {
      query += ' WHERE t.status = ?';
      args.add(status);
    }
    
    query += ' ORDER BY t.date DESC';
    
    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    return maps.map((t) => AppTransaction.fromMap(t)).toList();
  }

  Future<int> markAllCustomerTransactionsAsPaid(int customerId) async {
    Database db = await instance.database;
    return await db.update(
      tableTransaction,
      {'status': 1},
      where: 'customer_id = ? AND status = 0',
      whereArgs: [customerId],
    );
  }
  
  Future<int> updateTransaction(AppTransaction transaction) async {
    Database db = await instance.database;
    return await db.update(
      tableTransaction,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> markTransactionAsPaid(int id) async {
    Database db = await instance.database;
    return await db.update(
      tableTransaction,
      {'status': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    Database db = await instance.database;
    return await db.delete(tableTransaction, where: 'id = ?', whereArgs: [id]);
  }
}
