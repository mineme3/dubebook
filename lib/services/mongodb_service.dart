import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';

class MongoDbService {
  static final MongoDbService instance = MongoDbService._internal();
  MongoDbService._internal();

  // A default local or remote connection string.
  // Can be updated via app settings screen for grading/production testing.
  String _connectionUri = "mongodb://localhost:27017/dubebook";
  Db? _db;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String get connectionUri => _connectionUri;

  Future<void> updateConnectionUri(String newUri) async {
    _connectionUri = newUri;
    await disconnect();
    await connect();
  }

  Future<bool> connect() async {
    if (_isConnected && _db != null) return true;

    try {
      debugPrint("Connecting to MongoDB at $_connectionUri...");
      _db = await Db.create(_connectionUri);
      await _db!.open();
      _isConnected = true;
      debugPrint("Successfully connected to MongoDB!");
      return true;
    } catch (e) {
      debugPrint("Failed to connect to MongoDB: $e");
      _isConnected = false;
      _db = null;
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      if (_db != null) {
        await _db!.close();
      }
    } catch (e) {
      debugPrint("Error disconnecting from MongoDB: $e");
    } finally {
      _db = null;
      _isConnected = false;
    }
  }

  // Check if network and database is fully online
  Future<bool> checkOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return await connect();
      }
    } catch (_) {}
    _isConnected = false;
    return false;
  }

  // Get a collection by name helper
  DbCollection? _getCollection(String name) {
    if (_db == null || !_isConnected) return null;
    return _db!.collection(name);
  }

  // --- CRUD USER OPERATIONS ---
  Future<Map<String, dynamic>?> insertUser(Map<String, dynamic> userMap) async {
    final online = await checkOnline();
    if (!online) return null;

    try {
      final coll = _getCollection('users');
      if (coll == null) return null;
      
      // Check if user already exists
      final existing = await coll.findOne(where.eq('email', userMap['email']));
      if (existing != null) return existing;

      final docId = ObjectId();
      userMap['_id'] = docId;
      await coll.insertOne(userMap);
      return userMap;
    } catch (e) {
      debugPrint("MongoDB user insert error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final online = await checkOnline();
    if (!online) return null;

    try {
      final coll = _getCollection('users');
      return await coll?.findOne(where.eq('email', email));
    } catch (e) {
      debugPrint("MongoDB user find error: $e");
      return null;
    }
  }

  Future<bool> updateUserPassword(String email, String newPasswordHash) async {
    final online = await checkOnline();
    if (!online) return false;

    try {
      final coll = _getCollection('users');
      await coll?.updateOne(
        where.eq('email', email),
        modify.set('password_hash', newPasswordHash),
      );
      return true;
    } catch (e) {
      debugPrint("MongoDB password update error: $e");
      return false;
    }
  }

  // --- CRUD CUSTOMER OPERATIONS ---
  Future<String?> insertCustomer(Map<String, dynamic> customerMap) async {
    final online = await checkOnline();
    if (!online) return null;

    try {
      final coll = _getCollection('customers');
      if (coll == null) return null;

      final docId = ObjectId();
      customerMap['_id'] = docId;
      await coll.insertOne(customerMap);
      return docId.toHexString();
    } catch (e) {
      debugPrint("MongoDB customer insert error: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getCustomersForShopkeeper(String shopkeeperEmail) async {
    final online = await checkOnline();
    if (!online) return [];

    try {
      final coll = _getCollection('customers');
      if (coll == null) return [];
      return await coll.find(where.eq('shopkeeper_email', shopkeeperEmail)).toList();
    } catch (e) {
      debugPrint("MongoDB getCustomers error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> findCustomerByEmailAndPhone(String email, String phone) async {
    final online = await checkOnline();
    if (!online) return null;

    try {
      final coll = _getCollection('customers');
      return await coll?.findOne(where.eq('email', email).eq('phone', phone));
    } catch (e) {
      debugPrint("MongoDB findCustomer error: $e");
      return null;
    }
  }

  Future<bool> updateCustomer(String remoteId, Map<String, dynamic> updates) async {
    final online = await checkOnline();
    if (!online) return false;

    try {
      final coll = _getCollection('customers');
      await coll?.updateOne(
        where.eq('_id', ObjectId.fromHexString(remoteId)),
        modify
            .set('name', updates['name'])
            .set('email', updates['email'])
            .set('phone', updates['phone'])
            .set('note', updates['note'])
            .set('deadline', updates['deadline']),
      );
      return true;
    } catch (e) {
      debugPrint("MongoDB updateCustomer error: $e");
      return false;
    }
  }

  Future<bool> deleteCustomer(String remoteId) async {
    final online = await checkOnline();
    if (!online) return false;

    try {
      final coll = _getCollection('customers');
      final transColl = _getCollection('transactions');
      
      final objId = ObjectId.fromHexString(remoteId);
      await coll?.deleteOne(where.eq('_id', objId));
      await transColl?.deleteMany(where.eq('customer_remote_id', remoteId));
      return true;
    } catch (e) {
      debugPrint("MongoDB deleteCustomer error: $e");
      return false;
    }
  }

  // --- CRUD TRANSACTION OPERATIONS ---
  Future<String?> insertTransaction(Map<String, dynamic> transMap) async {
    final online = await checkOnline();
    if (!online) return null;

    try {
      final coll = _getCollection('transactions');
      if (coll == null) return null;

      final docId = ObjectId();
      transMap['_id'] = docId;
      await coll.insertOne(transMap);
      return docId.toHexString();
    } catch (e) {
      debugPrint("MongoDB transaction insert error: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionsForCustomer(String customerRemoteId) async {
    final online = await checkOnline();
    if (!online) return [];

    try {
      final coll = _getCollection('transactions');
      if (coll == null) return [];
      return await coll.find(where.eq('customer_remote_id', customerRemoteId).sortBy('date', descending: true)).toList();
    } catch (e) {
      debugPrint("MongoDB getTransactions error: $e");
      return [];
    }
  }

  Future<bool> markAllCustomerTransactionsAsPaid(String customerRemoteId) async {
    final online = await checkOnline();
    if (!online) return false;

    try {
      final coll = _getCollection('transactions');
      await coll?.updateMany(
        where.eq('customer_remote_id', customerRemoteId).eq('status', 0),
        modify.set('status', 1),
      );
      return true;
    } catch (e) {
      debugPrint("MongoDB mark paid error: $e");
      return false;
    }
  }

  Future<bool> updateTransaction(String remoteId, Map<String, dynamic> updates) async {
    final online = await checkOnline();
    if (!online) return false;

    try {
      final coll = _getCollection('transactions');
      await coll?.updateOne(
        where.eq('_id', ObjectId.fromHexString(remoteId)),
        modify
            .set('item_name', updates['item_name'])
            .set('quantity', updates['quantity'])
            .set('price', updates['price'])
            .set('total', updates['total'])
            .set('status', updates['status']),
      );
      return true;
    } catch (e) {
      debugPrint("MongoDB updateTransaction error: $e");
      return false;
    }
  }

  Future<bool> deleteTransaction(String remoteId) async {
    final online = await checkOnline();
    if (!online) return false;

    try {
      final coll = _getCollection('transactions');
      await coll?.deleteOne(where.eq('_id', ObjectId.fromHexString(remoteId)));
      return true;
    } catch (e) {
      debugPrint("MongoDB deleteTransaction error: $e");
      return false;
    }
  }
}
