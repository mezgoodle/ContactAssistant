import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:contact_assistant/data/models/contact.dart';
import 'package:contact_assistant/data/repositories/contacts_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'contact_provider.g.dart';

@riverpod
ContactsRepository contactsRepository(ContactsRepositoryRef ref) {
  final box = Hive.box<Contact>('contacts');
  return ContactsRepository(box);
}

@riverpod
class Contacts extends _$Contacts {
  @override
  Stream<List<Contact>> build() {
    final repository = ref.watch(contactsRepositoryProvider);
    return repository.watchAll();
  }

  Future<void> addContact(Contact contact) async {
    final repository = ref.read(contactsRepositoryProvider);
    // Generate ID if empty (though UI might handle it, safer here)
    if (contact.id.isEmpty) {
      // Simple ID generation
      contact.id = DateTime.now().millisecondsSinceEpoch.toString();
    }
    await repository.add(contact);
  }

  Future<void> updateContact(Contact contact) async {
    final repository = ref.read(contactsRepositoryProvider);
    await repository.update(contact);
  }

  Future<void> deleteContact(String id) async {
    final repository = ref.read(contactsRepositoryProvider);
    await repository.delete(id);
  }

  Future<void> markAsContacted(Contact contact) async {
    final repository = ref.read(contactsRepositoryProvider);
    contact.lastContacted = DateTime.now();
    await repository.update(contact);
  }
}
