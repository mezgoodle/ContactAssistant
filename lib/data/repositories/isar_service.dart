import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:contact_assistant/data/models/contact.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [ContactSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> saveContact(Contact contact) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.contacts.putSync(contact));
  }

  Future<void> deleteContact(int id) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.contacts.deleteSync(id));
  }

  Future<List<Contact>> getAllContacts() async {
    final isar = await db;
    return await isar.contacts.where().findAll();
  }

  Stream<List<Contact>> listenToContacts() async* {
    final isar = await db;
    yield* isar.contacts.where().watch(fireImmediately: true);
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }
}
