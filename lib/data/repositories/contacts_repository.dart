import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:contact_assistant/data/models/contact.dart';
import 'package:contact_assistant/core/utils/mongodb_service.dart';

class ContactsRepository {
  final DbCollection _collection;
  final _controller = StreamController<List<Contact>>.broadcast();

  ContactsRepository() : _collection = MongoDbService().contacts;

  Future<List<Contact>> getAll() async {
    final docs = await _collection.find().toList();
    final contacts = docs.map((doc) => Contact.fromJson(doc)).toList();
    contacts.sort((a, b) {
      if (a.lastContacted == null && b.lastContacted == null) return 0;
      if (a.lastContacted == null) return -1;
      if (b.lastContacted == null) return 1;
      return a.lastContacted!.compareTo(b.lastContacted!);
    });
    return contacts;
  }

  Stream<List<Contact>> watchAll() async* {
    yield await getAll();
    yield* _controller.stream;
  }

  Future<void> _notifyListeners() async {
    _controller.add(await getAll());
  }

  Future<void> add(Contact contact) async {
    if (contact.id.isEmpty) {
      throw ArgumentError('Contact ID cannot be empty');
    }
    await _collection.insertOne(contact.toJson());
    await _notifyListeners();
  }

  Future<void> update(Contact contact) async {
    // replaceOne with $set — must NOT include _id in the update doc
    final doc = Map<String, dynamic>.from(contact.toJson())..remove('_id');
    await _collection.updateOne(
      where.eq('_id', contact.id),
      modify
          .set('name', doc['name'])
          .set('phoneNumber', doc['phoneNumber'])
          .set('email', doc['email'])
          .set('telegramHandle', doc['telegramHandle'])
          .set('instagramHandle', doc['instagramHandle'])
          .set('location', doc['location'])
          .set('notes', doc['notes'])
          .set('lastContacted', doc['lastContacted'])
          .set('followUpFrequency', doc['followUpFrequency'])
          .set('tags', doc['tags']),
    );
    await _notifyListeners();
  }

  Future<void> delete(String id) async {
    await _collection.deleteOne(where.eq('_id', id));
    await _notifyListeners();
  }

  void dispose() {
    _controller.close();
  }
}
