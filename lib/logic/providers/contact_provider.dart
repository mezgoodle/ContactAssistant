import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:contact_assistant/data/models/contact.dart';
import 'package:contact_assistant/data/repositories/isar_service.dart';

part 'contact_provider.g.dart';

@riverpod
IsarService isarService(IsarServiceRef ref) {
  return IsarService();
}

@riverpod
class Contacts extends _$Contacts {
  @override
  Stream<List<Contact>> build() {
    final isarService = ref.watch(isarServiceProvider);
    return isarService.listenToContacts();
  }

  Future<void> addContact(Contact contact) async {
    final isarService = ref.read(isarServiceProvider);
    await isarService.saveContact(contact);
  }

  Future<void> updateContact(Contact contact) async {
    final isarService = ref.read(isarServiceProvider);
    await isarService.saveContact(contact);
  }

  Future<void> deleteContact(int id) async {
    final isarService = ref.read(isarServiceProvider);
    await isarService.deleteContact(id);
  }

  Future<void> markAsContacted(Contact contact) async {
    final isarService = ref.read(isarServiceProvider);
    contact.lastContacted = DateTime.now();
    await isarService.saveContact(contact);
  }
}
