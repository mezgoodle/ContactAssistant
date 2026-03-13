// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsRepositoryHash() =>
    r'7dcb9b89eae32296314d926a7555a0988563b5a1';

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
String _$contactsHash() => r'208a08aeee4872f0b0d43c0276b1f34b2c219de0';

/// See also [Contacts].
@ProviderFor(Contacts)
final contactsProvider =
    AutoDisposeStreamNotifierProvider<Contacts, List<Contact>>.internal(
  Contacts.new,
  name: r'contactsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$contactsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Contacts = AutoDisposeStreamNotifier<List<Contact>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
