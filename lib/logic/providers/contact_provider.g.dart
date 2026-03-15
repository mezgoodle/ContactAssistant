// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsRepositoryHash() =>
    r'f684ca6cf9947ebbad671101ca045fea82a069aa';

/// See also [contactsRepository].
@ProviderFor(contactsRepository)
final contactsRepositoryProvider =
    AutoDisposeProvider<ContactsRepository>.internal(
  contactsRepository,
  name: r'contactsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ContactsRepositoryRef = AutoDisposeProviderRef<ContactsRepository>;
String _$contactsHash() => r'04b154c58d522f42b479bf2300e8d44a0760faaf';

/// See also [Contacts].
@ProviderFor(Contacts)
final contactsProvider =
    AutoDisposeAsyncNotifierProvider<Contacts, List<Contact>>.internal(
  Contacts.new,
  name: r'contactsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$contactsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Contacts = AutoDisposeAsyncNotifier<List<Contact>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
