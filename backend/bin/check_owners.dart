import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  print('Connecting to MongoDB Atlas...');
  final db = await Db.create('mongodb+srv://sadiqsaladin_db_user:YhNS5EvPW2HEI7nv@cluster0.6fnq7ti.mongodb.net/creditdb?appName=Cluster0');
  await db.open();
  print('Connected!');
  
  final list = await db.collection('owners').find().toList();
  print('Registered owners: ${list.length}');
  for (final u in list) {
    print('- Email: ${u['email']}, Phone: ${u['phone']}, FullName: ${u['fullName']}');
  }
  await db.close();
}
