import 'package:hive_flutter/hive_flutter.dart';
import 'package:contact_assistant/data/models/contact.dart';

class ContactsRepository {
  final Box<Contact> _box;

  ContactsRepository(this._box);

  List<Contact> getAll() {
    final contacts = _box.values.toList();
    // Sort by lastContacted (Ascending) as per requirement
    // "implement a method that returns the contacts sorted by lastContacted date (Ascending)"
    // Note: lastContacted can be null. Let's assume nulls come first or last.
    // Ascending means oldest first. Null (never contacted) should probably be first or last?
    // Usually "Never contacted" is important, so maybe first?
    // Let's put nulls first (never contacted).
    contacts.sort((a, b) {
      if (a.lastContacted == null && b.lastContacted == null) return 0;
      if (a.lastContacted == null) return -1;
      if (b.lastContacted == null) return 1;
      return a.lastContacted!.compareTo(b.lastContacted!);
    });
    return contacts;
  }

  Stream<List<Contact>> watch() {
    return _box.watch().map((event) => getAll());
  }

  // Also provide a way to get initial value for StreamProvider if needed,
  // but usually we just return a stream that emits current value first.
  // Hive's watch() doesn't emit current value immediately.
  // We can merge it.

  Stream<List<Contact>> watchAll() async* {
    yield getAll();
    yield* _box.watch().map((_) => getAll());
  }

  Future<void> add(Contact contact) async {
    // We are using String id.
    // If contact.id is empty, generate one?
    // The UI might have already set it?
    // Let's assume the UI or Logic sets it, or we set it here if empty.
    // But `id` is `late String`.
    // If we use `box.put(key, value)`, we can use the ID as the key.
    if (contact.id.isEmpty) {
      throw ArgumentError('Contact ID cannot be empty');
    }
    if (contact.isInBox) {
      await contact.save();
    } else {
      await _box.put(contact.id, contact);
    }
  }

  Future<void> update(Contact contact) async {
    await _box.put(contact.id, contact);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
