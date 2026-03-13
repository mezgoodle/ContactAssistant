import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:contact_assistant/data/models/contact.dart';
import 'package:contact_assistant/data/repositories/contacts_repository.dart';

part 'contact_provider.g.dart';

@riverpod
ContactsRepository contactsRepository(ContactsRepositoryRef ref) {
  final repo = ContactsRepository();
  ref.onDispose(repo.dispose);
  return repo;
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
    final contactToAdd = contact.id.isEmpty
        ? contact.copyWith(
            id: '${DateTime.now().millisecondsSinceEpoch}_${contact.hashCode}',
          )
        : contact;
    await repository.add(contactToAdd);
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
    await repository.update(contact.copyWith(lastContacted: DateTime.now()));
  }
}
