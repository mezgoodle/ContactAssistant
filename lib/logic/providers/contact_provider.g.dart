// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsRepositoryHash() =>
    r'c2fced4c090ac1518227550876005c8e21b24ce6';

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
String _$contactsHash() => r'4cae48ccce2641a994acda948a6d6585c148250f';

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
