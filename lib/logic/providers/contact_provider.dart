import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:contact_assistant/data/models/contact.dart';
import 'package:contact_assistant/data/repositories/contacts_repository.dart';

part 'contact_provider.g.dart';

@riverpod
ContactsRepository contactsRepository(ContactsRepositoryRef ref) {
  return ContactsRepository();
}

@riverpod
class Contacts extends _$Contacts {
  @override
  Future<List<Contact>> build() {
    final repository = ref.watch(contactsRepositoryProvider);
    return repository.getAll();
  }

  Future<void> addContact(Contact contact) async {
    final repository = ref.read(contactsRepositoryProvider);
    final contactToAdd = contact.id.isEmpty
        ? contact.copyWith(
            id: '${DateTime.now().millisecondsSinceEpoch}_${contact.hashCode}',
          )
        : contact;
    await repository.add(contactToAdd);
    ref.invalidateSelf();
  }

  Future<void> updateContact(Contact contact) async {
    final repository = ref.read(contactsRepositoryProvider);
    await repository.update(contact);
    ref.invalidateSelf();
  }

  Future<void> deleteContact(String id) async {
    final repository = ref.read(contactsRepositoryProvider);
    await repository.delete(id);
    ref.invalidateSelf();
  }

  Future<void> markAsContacted(Contact contact) async {
    final repository = ref.read(contactsRepositoryProvider);
    await repository.update(contact.copyWith(lastContacted: DateTime.now()));
    ref.invalidateSelf();
  }
}
